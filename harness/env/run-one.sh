# run-one.sh <plan> <run-id>: one agent run, as docs/DESIGN.md describes it, into results/<plan>/runs/<run-id>/.
set -euo pipefail
. "$STUDY_ROOT/harness/env/lib.sh"
plan=$1 rid=$2; P=$STUDY_ROOT/results/$plan; out=$P/runs/$rid
line=$(awk -F'\t' -v r="$rid" '$1==r' "$P/plan.tsv"); [ -n "$line" ] || die "no run $rid in $P/plan.tsv"
IFS=$'\t' read -r _ proj task arm model rep effort budget turns tmo <<<"$line"
[ -f "$out/exit.json" ] && { log "skip $rid (done)"; exit 0; }
# A usage or rate limit was hit a moment ago (by this or a parallel run): do not start, ./study run waits and retries.
[ -f "$P/.limit" ] && { log "skip $rid (limit hit, waiting)"; exit 75; }
td=$STUDY_ROOT/tasks/$proj/$task
snap=$(state_dir "$proj" "$(task_commit "$proj" "$td")")/snapshot; [ -d "$snap" ] || die "project $proj is not set up at this task's commit: ./study project $proj"
w=$STUDY_STATE/runs/$plan/$rid; rm -rf "$w" "$out"; mkdir -p "$w/in" "$w/home" "$w/sock" "$w/lsplog" "$w/lic" "$out"
chmod 0777 "$w/sock"

# The starting state: the snapshot, the task's setup and the arm's files, as one fresh commit (no history to read).
g() { git -c user.name=study -c user.email=study@localhost "$@"; }
cp -a "$snap" "$w/ws"
[ -s "$td/setup.patch" ] && g -C "$w/ws" apply --whitespace=nowarn "$td/setup.patch"
ov=$STUDY_ROOT/harness/arms/$arm/overlay; [ -d "$ov" ] || ov=$STUDY_ROOT/harness/arms/${arm#intellij-}/overlay
case "$arm" in baseline|baseline-review) ;; *) [ -d "$ov" ] && cp -a "$ov/." "$w/ws/" ;; esac
rm -rf "$w/ws/.git" && g -C "$w/ws" init -q -b main && g -C "$w/ws" add -A && g -C "$w/ws" commit -qm "$proj"
base=$(g -C "$w/ws" rev-parse HEAD); echo "$base" > "$out/base-commit"

{ cat "$STUDY_ROOT/harness/prompt-preamble.md"; cat "$td/prompt.md"; } > "$w/in/prompt.md"
lsp=1; case "$arm" in baseline|baseline-review) lsp=0 ;; esac
if [ "$lsp" = 1 ]; then
  printf '{"mcpServers":{"tereditor":{"command":"socat","args":["STDIO","UNIX-CONNECT:/run/study/mcp.sock"]}}}\n' > "$w/in/mcp.json"
  if [ -n "${STUDY_LICENSE_ZIP_B64:-}" ]; then printf '%s' "$STUDY_LICENSE_ZIP_B64" | base64 -d > "$w/lic/${STUDY_LICENSE_NAME:-license.zip}"; fi
  socat UNIX-LISTEN:"$w/sock/mcp.sock",fork,mode=0777 \
    EXEC:"$STUDY_HOST/bin/bash $STUDY_ROOT/harness/env/serve-conn.sh $arm $w/ws $w/lsplog $w/lic" &
  bridge=$!
fi
unset STUDY_LICENSE_ZIP_B64

# The agent's only way out: the egress socket, behind which only the allowlist of harness/egress-allow.txt is reachable.
socat UNIX-LISTEN:"$w/sock/egress.sock",fork,mode=0777 EXEC:"bash $STUDY_ROOT/harness/env/egress-conn.sh $w/egress.log" &
egress=$!
for _ in $(seq 1 50); do [ -S "$w/sock/egress.sock" ] && break; sleep 0.1; done

# The agent: built-in tools Bash, Read, Edit, Write, Task (subagents) and ToolSearch (MCP tools are deferred behind it).
args=(-p "$(cat "$w/in/prompt.md")" --model "$model" --output-format stream-json --verbose
      --setting-sources project --strict-mcp-config --permission-mode bypassPermissions
      --tools "Bash,Read,Edit,Write,Task,ToolSearch" --disallowedTools "WebFetch,WebSearch"
      --max-budget-usd "$budget" --max-turns "$turns")
[ "$effort" != - ] && args+=(--effort "$effort")
[ "$lsp" = 1 ] && args+=(--mcp-config /in/mcp.json)
# baseline-review keeps its session for the second prompt; every other arm persists nothing.
sid=
if [ "$arm" = baseline-review ]; then sid=$(cat /proc/sys/kernel/random/uuid); args+=(--session-id "$sid"); else args+=(--no-session-persistence); fi
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
if [ -n "$sid" ] && [ "$rc" = 0 ]; then
  cp "$STUDY_ROOT/harness/review-prompt.md" "$w/in/review.md"
  rargs=(); skip=0
  for a in "${args[@]}"; do
    if [ "$skip" = 1 ]; then skip=0; continue; fi
    case "$a" in -p|--session-id) skip=1; continue ;; esac
    rargs+=("$a")
  done
  ( agent_exec "$w/ws" "$w/home" "$w/in" "$w/sock" timeout --kill-after=30 "$tmo" claude -p "$(cat "$w/in/review.md")" --resume "$sid" "${rargs[@]}" ) \
    > "$out/stream-review.jsonl" 2> "$out/claude-review.stderr"
  rc=$?
fi
set -e
end=$(date +%s.%N)
[ -n "${bridge:-}" ] && { kill "$bridge" 2>/dev/null || true; wait "$bridge" 2>/dev/null || true; }
kill "$egress" 2>/dev/null || true; wait "$egress" 2>/dev/null || true

# A run that stopped on a usage, quota or rate limit is not a result: log the attempt's cost, discard it, flag the limit
# so ./study run waits and starts this run again from the beginning with the same run id.
limit_re='limit reached|usage limit|session limit|rate.?limit|quota|credit balance|overloaded|too many requests'
if { jq -r 'select(.type=="result" and .is_error==true) | (.result // "")' "$out/stream.jsonl" 2>/dev/null; \
     [ -s "$out/stream-review.jsonl" ] && jq -r 'select(.type=="result" and .is_error==true) | (.result // "")' "$out/stream-review.jsonl" 2>/dev/null; } \
   | grep -q -i -E "$limit_re"; then
  cost=$(jq -s '[.[] | select(.type=="result") | .total_cost_usd // 0] | add // 0' "$out/stream.jsonl" 2>/dev/null || echo 0)
  printf '%s\t%s\tcost_usd=%s\n' "$(date -u +%FT%TZ)" "$rid" "${cost:-0}" >> "$P/limit-attempts.log"
  touch "$P/.limit"; log "run $rid stopped on a usage limit; discarded, will be retried"
  rm -rf "$w" "$out"; exit 75
fi
g -C "$w/ws" add -A >/dev/null 2>&1 || true
g -C "$w/ws" diff --cached --binary "$base" > "$out/patch.diff" || true
[ -f "$w/ws/ANSWER.txt" ] && cp "$w/ws/ANSWER.txt" "$out/"
mkdir -p "$out/lsplog" "$out/in"; cp -a "$w/lsplog/." "$out/lsplog/" 2>/dev/null || true; cp -a "$w/in/." "$out/in/"; cp "$w/egress.log" "$out/" 2>/dev/null || true
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
