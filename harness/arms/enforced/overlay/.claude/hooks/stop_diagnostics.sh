#!/bin/bash
# Blocks the stop once when source files were edited after the last lsp_diagnostics call (or with none at all).
. "$(dirname "$0")/common.sh"
in=$(cat)
[ "$(jq -r '.stop_hook_active // false' <<<"$in")" = true ] && exit 0
transcript=$(jq -r '.transcript_path // ""' <<<"$in")
[ -f "$transcript" ] || exit 0
# Ordered tool uses of the main conversation: "edit<TAB>path" or "diag".
uses=$(jq -r --arg ext "$SOURCE_EXT" '
  select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") |
  if (.name == "Edit" or .name == "Write" or .name == "MultiEdit") and ((.input.file_path // "") | test($ext)) then "edit\t" + .input.file_path
  elif (.name | endswith("lsp_diagnostics")) then "diag"
  elif (.name | endswith("lsp_rename")) or (.name | endswith("lsp_code_actions")) then "edit\t(lsp)"
  else empty end' "$transcript" 2>/dev/null)
pending=$(awk -F'\t' '$1=="diag"{delete e; next} $1=="edit"{e[$2]=1} END{for(k in e) print k}' <<<"$uses" | grep -v '^(lsp)$' | sort)
last=$(tail -n1 <<<"$uses")
if [ -n "$pending" ] || [ "${last%%$'\t'*}" = edit ]; then
  files=$(paste -sd, - <<<"$pending")
  jq -cn --arg r "CLAUDE.md: source files were edited after the last lsp_diagnostics check${files:+ ($files)}. Run mcp__tereditor__lsp_diagnostics with paths listing every file you edited and fix what it reports before finishing." \
    '{decision:"block", reason:$r}'
fi
