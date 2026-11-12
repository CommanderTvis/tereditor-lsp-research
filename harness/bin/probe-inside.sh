#!/bin/bash
# Runs inside a run image (entrypoint "probe" mode, as root). Talks MCP to headless SharpRail exactly as the agent
# would (same sudo wrapper), with no model involved. Input: /in/probe.json, a list of
#   {"name": "...", "tool": "lsp_navigate", "args": {...}, "expect": ["path:line", ...]}
# expect lists 1-based locations that a complete answer must contain. Each call is repeated until every expected
# location is present or POLL_S seconds pass, which measures how long the server takes to give a complete answer
# (a fresh server may answer before it has indexed the workspace).
# Output (/out): initialize.json, tools.json (as the agent sees them), probe.jsonl (one line per spec).
set -euo pipefail
mode=${1:-enforced}; POLL_S=${POLL_S:-180}
mkdir -p /out
rm -rf /workspace && cp -a /study/snapshot /workspace && chmod -R a+rwX /workspace
install -d -o sharprail -g sharprail -m 0700 /study/lsplog
# The IntelliJ licence, decoded exactly as the run entrypoint does it (only uid 1000 can read it).
rm -rf /study/license && install -d -o sharprail -g sharprail -m 0700 /study/license
if [ -n "${STUDY_LICENSE_ZIP_B64:-}" ]; then
  printf '%s' "$STUDY_LICENSE_ZIP_B64" | base64 -d > /study/license/license.zip
  chown sharprail:sharprail /study/license/license.zip && chmod 0400 /study/license/license.zip
fi
unset STUDY_LICENSE_ZIP_B64
coproc S { sudo -n -u sharprail /usr/local/bin/sharprail-mcp "$mode"; }
exec 3>&"${S[1]}" 4<&"${S[0]}"
send() { printf '%s\n' "$1" >&3; }
recv() { local line; while IFS= read -r -t 600 line <&4; do if jq -e --argjson id "$1" '.id == $id' >/dev/null 2>&1 <<<"$line"; then printf '%s\n' "$line"; return 0; fi; done; return 1; }
now() { date +%s.%N; }
calc() { awk "BEGIN{print $1}"; }
t0=$(now)
send '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"study-probe","version":"1"}}}'
recv 1 > /out/initialize.json
send '{"jsonrpc":"2.0","method":"notifications/initialized"}'
send '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
recv 2 > /out/tools.json
id=10
: > /out/probe.jsonl
# Locations in a result, as 1-based path:line (lsp_navigate reports 0-based lines; diagnostics too).
locs() { jq -r 'try ([.locations[]?, .diagnostics[]?] | .[] | select(.path and .line != null) | "\(.path):\(.line + 1)") catch empty' <<<"$1" | sort -u; }
while IFS= read -r spec; do
  name=$(jq -r .name <<<"$spec"); args=$(jq -c .args <<<"$spec"); tool=$(jq -r '.tool // "lsp_navigate"' <<<"$spec")
  start=$(now); attempts=0; first_answer=""
  while :; do
    id=$((id+1)); attempts=$((attempts+1))
    send "$(jq -cn --argjson id $id --arg t "$tool" --argjson a "$args" '{jsonrpc:"2.0",id:$id,method:"tools/call",params:{name:$t,arguments:$a}}')"
    resp=$(recv $id)
    text=$(jq -r '[.result.content[]?.text] | join("\n")' <<<"$resp")
    got=$(locs "$text")
    missing=$(jq -c --arg got "$got" '[.expect[]? | select(. as $e | ($got | split("\n") | index($e)) | not)]' <<<"$spec")
    if ! grep -qi '"state":"initializing"' <<<"$text" && [ -z "$first_answer" ]; then first_answer=$(calc "$(now) - $start"); fi
    [ "$missing" = "[]" ] && break
    [ "$(calc "($(now) - $start) < $POLL_S")" = 1 ] || break
    sleep 5
  done
  jq -cn --arg name "$name" --argjson attempts $attempts --arg secs "$(calc "$(now) - $start")" --arg first "${first_answer:-}" \
     --arg since0 "$(calc "$(now) - $t0")" --argjson missing "$missing" --arg got "$got" --arg text "$text" \
     '{name:$name, complete:($missing==[]), attempts:$attempts, secondsToComplete:($secs|tonumber), secondsToFirstAnswer:(if $first=="" then null else ($first|tonumber) end),
       sinceServerStart:($since0|tonumber), missing:$missing, found:($got|split("\n")|map(select(.!=""))), lastResult:$text}' >> /out/probe.jsonl
done < <(jq -c '.[]' /in/probe.json)
exec 3>&- 4<&-
kill "$S_PID" 2>/dev/null || true
wait 2>/dev/null || true
cp -a /study/lsplog/. /out/lsplog/ 2>/dev/null || true
[ -n "${STUDY_HOST_UID:-}" ] && chown -R "$STUDY_HOST_UID:${STUDY_HOST_GID:-$STUDY_HOST_UID}" /out 2>/dev/null || true
