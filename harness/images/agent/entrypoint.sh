#!/bin/bash
# One study run. Starts as root, prepares a fresh workspace, runs Claude Code as uid 1001 (agent), collects outputs.
#
# Mounts:   /in   (read-only)  prompt.md, arm/ (overlay copied into the workspace), mcp.json (absent for baseline)
#           /out  (read-write) everything this run produces
# Env:      ARM, MODEL, EFFORT (optional), MAX_BUDGET_USD, MAX_TURNS, TIMEOUT_S, ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN
# Image:    /study/snapshot holds the project at its pinned commit as a one-commit git repo (built per project).
set -euo pipefail

if [ "${1:-run}" = "probe" ]; then shift; exec "$@"; fi

: "${ARM:?}" "${MODEL:?}" "${MAX_BUDGET_USD:?}" "${MAX_TURNS:=200}" "${TIMEOUT_S:=3600}"
out=/out
mkdir -p "$out"

cd /
# Fresh workspace from the snapshot. Both the agent and the language server (uid 1000) must write to it.
rm -rf /workspace && cp -a /study/snapshot /workspace
git() { command git -c user.name=study -c user.email=study@localhost "$@"; }
if [ -s /in/setup.patch ]; then
  git -C /workspace apply --whitespace=nowarn /in/setup.patch
  git -C /workspace add -A && git -C /workspace commit -qm "task setup"
fi
if [ -d /in/arm ] && [ -n "$(ls -A /in/arm)" ]; then
  cp -a /in/arm/. /workspace/
  git -C /workspace add -A && git -C /workspace commit -qm "arm overlay: $ARM"
fi
git -C /workspace rev-parse HEAD > "$out/base-commit"
chown -R agent:agent /workspace && chmod -R a+rwX /workspace

# The JetBrains licence for the IntelliJ arms: decoded into a directory only uid 1000 (the server) can read. The agent's
# environment is rebuilt from nothing below (env -i), so the variable never reaches it either.
rm -rf /study/license && install -d -o sharprail -g sharprail -m 0700 /study/license
if [ -n "${STUDY_LICENSE_ZIP_B64:-}" ]; then
  printf '%s' "$STUDY_LICENSE_ZIP_B64" | base64 -d > /study/license/license.zip
  chown sharprail:sharprail /study/license/license.zip && chmod 0400 /study/license/license.zip
fi
unset STUDY_LICENSE_ZIP_B64

# A per-run language-server call log, written by uid 1000 and collected afterwards.
rm -rf /study/lsplog && install -d -o sharprail -g sharprail -m 0700 /study/lsplog

args=(-p "$(cat /in/prompt.md)"
      --model "$MODEL"
      --output-format stream-json --verbose
      --setting-sources project
      --strict-mcp-config
      --no-session-persistence
      --permission-mode bypassPermissions
      --disallowedTools "WebFetch,WebSearch"
      --max-budget-usd "$MAX_BUDGET_USD"
      --max-turns "$MAX_TURNS")
[ -n "${EFFORT:-}" ] && args+=(--effort "$EFFORT")
[ -f /in/mcp.json ] && args+=(--mcp-config /in/mcp.json)

start=$(date +%s.%N)
set +e
# setpriv drops to the agent user. HOME is a fresh, empty directory in every run: no user CLAUDE.md, settings,
# plugins, skills or memory exist. SUBPROCESS_ENV_SCRUB=1 is off: in 2.1.322 it forces the default permission mode, a
# bubblewrap+socat sandbox for Bash and drops Grep, which would change the agent itself. Outputs are redacted instead.
timeout --kill-after=30 "$TIMEOUT_S" \
  setpriv --reuid=agent --regid=agent --init-groups \
  env -i PATH=/usr/local/bin:/usr/bin:/bin HOME=/home/agent USER=agent LANG=C.UTF-8 TERM=dumb \
      DISABLE_AUTOUPDATER=1 DISABLE_TELEMETRY=1 DISABLE_ERROR_REPORTING=1 \
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 IS_SANDBOX=1 CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0 \
      ${ANTHROPIC_API_KEY:+ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"} \
      ${CLAUDE_CODE_OAUTH_TOKEN:+CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN"} \
      bash -c 'cd /workspace && exec claude "$@"' claude "${args[@]}" \
  > "$out/stream.jsonl" 2> "$out/claude.stderr"
rc=$?
set -e
end=$(date +%s.%N)

# Outputs: the change, any answer file, the language-server log, timings.
git -C /workspace add -A >/dev/null 2>&1 || true
git -C /workspace diff --cached --binary "$(cat "$out/base-commit")" > "$out/patch.diff" || true
[ -f /workspace/ANSWER.txt ] && cp /workspace/ANSWER.txt "$out/ANSWER.txt"
cp -a /study/lsplog/. "$out/lsplog/" 2>/dev/null || mkdir -p "$out/lsplog"
printf '{"exit":%d,"start":%s,"end":%s}\n' "$rc" "$start" "$end" > "$out/exit.json"

# Never let a credential reach the results, whatever the agent printed.
for secret in "${ANTHROPIC_API_KEY:-}" "${CLAUDE_CODE_OAUTH_TOKEN:-}"; do
  [ -n "$secret" ] || continue
  grep -rlF -- "$secret" "$out" 2>/dev/null | while read -r f; do sed -i "s|$secret|<REDACTED>|g" "$f"; done || true
done
[ -n "${STUDY_HOST_UID:-}" ] && chown -R "$STUDY_HOST_UID:${STUDY_HOST_GID:-$STUDY_HOST_UID}" /out 2>/dev/null || true
exit 0
