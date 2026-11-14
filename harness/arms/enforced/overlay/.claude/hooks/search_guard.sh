#!/bin/bash
# Advisory only: when a text search looks like a symbol lookup, point at lsp_navigate. Never blocks.
. "$(dirname "$0")/common.sh"
in=$(cat)
tool=$(jq -r '.tool_name // ""' <<<"$in")
case "$tool" in
  Grep) pattern=$(jq -r '.tool_input.pattern // ""' <<<"$in") ;;
  Glob) exit 0 ;;
  Bash)
    cmd=$(jq -r '.tool_input.command // ""' <<<"$in")
    grep -qE '(^|[|;&[:space:]])(grep|egrep|rg|ag|ack|git grep)([[:space:]]|$)' <<<"$cmd" || exit 0
    pattern=$cmd ;;
  *) exit 0 ;;
esac
# A symbol-like pattern: camelCase, PascalCase with two humps, snake_case, Type.member / Type::member, or a \\b-wrapped word.
if grep -qE '[a-z][a-z0-9]*[A-Z][A-Za-z0-9]*|[A-Z][a-z0-9]+[A-Z][A-Za-z0-9]*|[A-Za-z0-9]_[A-Za-z]|[A-Za-z_][A-Za-z0-9_]*(\.|::|->)[A-Za-z_][A-Za-z0-9_]*\(|\\b[A-Za-z_]|(def|class|function|func|fun|interface|struct|enum|trait|type|new)[[:space:]]+[A-Za-z_]|-w[[:space:]]|--word-regexp' <<<"$pattern"; then
  emit_context PreToolUse "CLAUDE.md: this looks like symbol work. Use mcp__tereditor__lsp_navigate (references, definition, implementation, incomingCalls, workspaceSymbols) instead of text search: grep misses implementations, overrides and indirection and matches unrelated names. Text search is fine for literals, comments, config and docs."
fi
