# review-one.sh <plan> <run-id>: the post-hoc quality review of an edit run's diff (docs/ANALYSIS_PLAN.md, outcome 3)
# into results/<plan>/runs/<run-id>/review/. The reviewer (claude-haiku-5-5) sees the task prompt, the diff and the
# edited tree, read-only in intent; never the gold patch, never the arm (the arm's overlay files are not in its tree or
# diff). It never decides pass or fail.
set -euo pipefail
. "$STUDY_ROOT/harness/env/lib.sh"
plan=$1 rid=$2; P=$STUDY_ROOT/results/$plan; out=$P/runs/$rid; rv=$out/review
[ -f "$out/exit.json" ] || exit 0
[ -f "$rv/result.json" ] && exit 0
line=$(awk -F'\t' -v r="$rid" '$1==r' "$P/plan.tsv"); proj=$(echo "$line" | cut -f2); task=$(echo "$line" | cut -f3)
td=$STUDY_ROOT/tasks/$proj/$task
type=$(toml_val "$td/task.toml" type)
mkdir -p "$rv"
skip() { printf '{"flaws":null,"skipped":"%s","cost_usd":0}\n' "$1" > "$rv/result.json"; exit 0; }
case "$type" in refs|impls|dispatch|callers|inspect) skip "answer task" ;; esac
snap=$(state_dir "$proj" "$(task_commit "$proj" "$td")")/snapshot; [ -d "$snap" ] || die "project $proj is not set up at this task's commit: ./study project $proj"
g() { git -c user.name=study -c user.email=study@localhost "$@"; }
w=$STUDY_STATE/runs/review-$plan/$rid; rm -rf "$w"; mkdir -p "$w/in" "$w/home" "$w/sock"; chmod 0777 "$w/sock"
cp -a "$snap" "$w/ws"
[ -s "$td/setup.patch" ] && g -C "$w/ws" apply --whitespace=nowarn "$td/setup.patch"
rm -rf "$w/ws/.git" && g -C "$w/ws" init -q -b main && g -C "$w/ws" add -A && g -C "$w/ws" commit -qm "$proj"
# The agent's diff without the arm's files (the enforced overlay and anything its hooks wrote) and without ANSWER.txt.
if ! g -C "$w/ws" apply --whitespace=nowarn --binary --exclude='.claude/*' --exclude=CLAUDE.md --exclude=ANSWER.txt "$out/patch.diff" 2>"$rv/apply.log"; then
  rm -rf "$w"; skip "patch does not apply"
fi
g -C "$w/ws" add -A && g -C "$w/ws" diff --cached HEAD > "$w/in/patch.diff"
[ -s "$w/in/patch.diff" ] || { rm -rf "$w"; skip "empty diff"; }
rm -rf "$w/ws/.git"   # no history to compare against: the diff is the change
cp "$td/prompt.md" "$w/in/task.md"
cp "$STUDY_ROOT/harness/judge/prompt.md" "$w/in/review.md"
cp "$w/in/patch.diff" "$rv/patch.reviewed.diff"
socat UNIX-LISTEN:"$w/sock/egress.sock",fork,mode=0777 EXEC:"bash $STUDY_ROOT/harness/env/egress-conn.sh $w/egress.log" &
egress=$!
for _ in $(seq 1 50); do [ -S "$w/sock/egress.sock" ] && break; sleep 0.1; done
args=(-p "$(cat "$w/in/review.md")" --model claude-haiku-5-5 --output-format stream-json --verbose
      --setting-sources project --strict-mcp-config --permission-mode bypassPermissions --no-session-persistence
      --tools "Bash,Read" --disallowedTools "WebFetch,WebSearch" --max-budget-usd 1 --max-turns 60)
AGENT_ENV=(DISABLE_AUTOUPDATER=1 DISABLE_TELEMETRY=1 DISABLE_ERROR_REPORTING=1 CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 IS_SANDBOX=1)
[ -n "${ANTHROPIC_API_KEY:-}" ] && AGENT_ENV+=(ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY")
[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ] && AGENT_ENV+=(CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN")
# A review stopped on a usage limit is not a result either: wait until the limit resets and review again, as long as it takes.
while :; do
  set +e
  ( agent_exec "$w/ws" "$w/home" "$w/in" "$w/sock" timeout --kill-after=30 1200 claude "${args[@]}" ) > "$rv/stream.jsonl" 2> "$rv/claude.stderr"
  set -e
  if limit_stop "$rv/stream.jsonl"; then
    c=$(jq -s '[.[] | select(type=="object" and .type=="result") | .total_cost_usd // 0] | add // 0' "$rv/stream.jsonl" 2>/dev/null || echo 0)
    printf '%s\treview-%s\tcost_usd=%s\n' "$(date -u +%FT%TZ)" "$rid" "${c:-0}" >> "$P/limit-attempts.log"
    ws=$(limit_wait_s "$rv/stream.jsonl"); log "review $rid stopped on a usage limit; waiting $ws s"; sleep "$ws"; continue
  fi
  break
done
kill "$egress" 2>/dev/null || true; wait "$egress" 2>/dev/null || true
cost=$(jq -s '[.[] | select(.type=="result") | .total_cost_usd // 0] | add // 0' "$rv/stream.jsonl" 2>/dev/null || echo 0)
text=$(jq -r 'select(.type=="result") | .result // ""' "$rv/stream.jsonl" 2>/dev/null | tail -n 200)
obj=$(printf '%s\n' "$text" | grep -E '^\s*\{.*"flaws"' | tail -n1 || true)
if [ -n "$obj" ] && printf '%s' "$obj" | jq -e '.flaws | type == "array"' >/dev/null 2>&1; then
  printf '%s' "$obj" | jq -c --argjson c "${cost:-0}" '{flaws: (.flaws | length), items: .flaws, cost_usd: $c, parsed: true}' > "$rv/result.json"
else
  jq -nc --argjson c "${cost:-0}" '{flaws: null, parsed: false, cost_usd: $c}' > "$rv/result.json"
fi
for tf in /home/claude/.claude/remote/.oauth_token /home/claude/.claude/remote/.session_ingress_token; do
  [ -s "$tf" ] || continue
  grep -rlF -f "$tf" "$rv" 2>/dev/null | while read -r f; do
    while IFS= read -r secret; do [ -n "$secret" ] && sed -i "s|$secret|<REDACTED>|g" "$f"; done < "$tf"
  done || true
done
rm -rf "$w"
echo "[env] reviewed $rid: $(cat "$rv/result.json" | jq -c '{flaws, parsed, cost_usd}')" >&2
