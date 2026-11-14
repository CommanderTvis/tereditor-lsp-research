#!/bin/bash
# Advisory only: on edits of source files, remind about lsp_rename and lsp_diagnostics. Never blocks.
. "$(dirname "$0")/common.sh"
in=$(cat)
path=$(jq -r '.tool_input.file_path // ""' <<<"$in")
grep -qE "$SOURCE_EXT" <<<"$path" || exit 0
if [ "$(jq -r '.tool_input.replace_all // false' <<<"$in")" = true ]; then
  msg="CLAUDE.md: renames should use mcp__tereditor__lsp_rename, which updates every reference semantically. Edit replace_all is a last resort."
else
  msg="CLAUDE.md: after editing, run mcp__tereditor__lsp_diagnostics with paths listing every file you edited; there is no compiler here. For renames use mcp__tereditor__lsp_rename."
fi
emit_context PreToolUse "$msg"
