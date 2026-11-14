# run-one.sh <plan> <run-id>: one agent run, as docs/DESIGN.md describes it, into results/<plan>/runs/<run-id>/.
set -euo pipefail
. "$STUDY_ROOT/harness/env/lib.sh"
plan=$1 rid=$2; P=$STUDY_ROOT/results/$plan; out=$P/runs/$rid
line=$(awk -F'\t' -v r="$rid" '$1==r' "$P/plan.tsv"); [ -n "$line" ] || die "no run $rid in $P/plan.tsv"
IFS=$'\t' read -r _ proj task arm model rep effort budget turns tmo <<<"$line"
[ -f "$out/exit.json" ] && { log "skip $rid (done)"; exit 0; }
snap=$STUDY_STATE/projects/$proj/snapshot; [ -d "$snap" ] || die "project $proj is not set up: ./study project $proj"
td=$STUDY_ROOT/tasks/$proj/$task
w=$STUDY_STATE/runs/$plan/$rid; rm -rf "$w" "$out"; mkdir -p "$w/in" "$w/home" "$w/sock" "$w/lsplog" "$w/lic" "$out"
chmod 0777 "$w/sock"

# The starting state: the snapshot, the task's setup and the arm's files, as one fresh commit (no history to read).
g() { git -c user.name=study -c user.email=study@localhost "$@"; }
cp -a "$snap" "$w/ws"
[ -s "$td/setup.patch" ] && g -C "$w/ws" apply --whitespace=nowarn "$td/setup.patch"
ov=$STUDY_ROOT/harness/arms/$arm/overlay; [ -d "$ov" ] || ov=$STUDY_ROOT/harness/arms/${arm#intellij-}/overlay
case "$arm" in baseline) ;; *) [ -d "$ov" ] && cp -a "$ov/." "$w/ws/" ;; esac
rm -rf "$w/ws/.git" && g -C "$w/ws" init -q -b main && g -C "$w/ws" add -A && g -C "$w/ws" commit -qm "$proj"
base=$(g -C "$w/ws" rev-parse HEAD); echo "$base" > "$out/base-commit"

{ cat "$STUDY_ROOT/harness/prompt-preamble.md"; cat "$td/prompt.md"; } > "$w/in/prompt.md"
if [ "$arm" != baseline ]; then
  printf '{"mcpServers":{"tereditor":{"command":"socat","args":["STDIO","UNIX-CONNECT:/run/study/mcp.sock"]}}}\n' > "$w/in/mcp.json"
  if [ -n "${STUDY_LICENSE_ZIP_B64:-}" ]; then printf '%s' "$STUDY_LICENSE_ZIP_B64" | base64 -d > "$w/lic/${STUDY_LICENSE_NAME:-license.zip}"; fi
  socat UNIX-LISTEN:"$w/sock/mcp.sock",fork,mode=0777 \
    EXEC:"$STUDY_HOST/bin/bash $STUDY_ROOT/harness/env/serve-conn.sh $arm $w/ws $w/lsplog $w/lic" &
  bridge=$!
fi
unset STUDY_LICENSE_ZIP_B64

# The agent: built-in tools Bash, Read, Edit, Write, Task (subagents) and ToolSearch (MCP tools are deferred behind it).
args=(-p "$(cat "$w/in/prompt.md")" --model "$model" --output-format stream-json --verbose
      --setting-sources project --strict-mcp-config --no-session-persistence --permission-mode bypassPermissions
      --tools "Bash,Read,Edit,Write,Task,ToolSearch" --disallowedTools "WebFetch,WebSearch"
      --max-budget-usd "$budget" --max-turns "$turns")
[ "$effort" != - ] && args+=(--effort "$effort")
[ "$arm" != baseline ] && args+=(--mcp-config /in/mcp.json)
AGENT_ENV=(DISABLE_AUTOUPDATER=1 DISABLE_TELEMETRY=1 DISABLE_ERROR_REPORTING=1 CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
           IS_SANDBOX=1)
[ -n "${ANTHROPIC_API_KEY:-}" ] && AGENT_ENV+=(ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY")
[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ] && AGENT_ENV+=(CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN")
log "run $rid $proj/$task arm=$arm model=$model"
start=$(date +%s.%N)
set +e
( agent_exec "$w/ws" "$w/home" "$w/in" "$w/sock" timeout --kill-after=30 "$tmo" claude "${args[@]}" ) \
  > "$out/stream.jsonl" 2> "$out/claude.stderr"
rc=$?
set -e
end=$(date +%s.%N)
[ -n "${bridge:-}" ] && { kill "$bridge" 2>/dev/null || true; wait "$bridge" 2>/dev/null || true; }

g -C "$w/ws" add -A >/dev/null 2>&1 || true
g -C "$w/ws" diff --cached --binary "$base" > "$out/patch.diff" || true
[ -f "$w/ws/ANSWER.txt" ] && cp "$w/ws/ANSWER.txt" "$out/"
mkdir -p "$out/lsplog" "$out/in"; cp -a "$w/lsplog/." "$out/lsplog/" 2>/dev/null || true; cp -a "$w/in/." "$out/in/"
printf '{"exit":%d,"start":%s,"end":%s}\n' "$rc" "$start" "$end" > "$out/exit.json"
# Never let a credential reach the results: the variables, and the cloud session's token file used as a pattern.
for secret in "${ANTHROPIC_API_KEY:-}" "${CLAUDE_CODE_OAUTH_TOKEN:-}"; do
  [ -n "$secret" ] || continue
  grep -rlF -- "$secret" "$out" 2>/dev/null | while read -r f; do sed -i "s|$secret|<REDACTED>|g" "$f"; done || true
done
for tf in /home/claude/.claude/remote/.oauth_token /home/claude/.claude/remote/.session_ingress_token; do
  [ -s "$tf" ] || continue
  grep -rlF -f "$tf" "$out" 2>/dev/null | while read -r f; do
    while IFS= read -r secret; do [ -n "$secret" ] && sed -i "s|$secret|<REDACTED>|g" "$f"; done < "$tf"
  done || true
done
rm -rf "$w"
[ -n "${STUDY_HOST_UID:-}" ] && chown -R "$STUDY_HOST_UID:${STUDY_HOST_GID:-$STUDY_HOST_UID}" "$out" 2>/dev/null || true
