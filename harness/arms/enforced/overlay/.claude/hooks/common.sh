# Shared by the hooks. Source file extensions that have a language server in headless Tereditor.
SOURCE_EXT='\.(cs|ts|tsx|mts|cts|js|jsx|mjs|cjs|py|pyi|php|c|h|cc|cpp|cxx|hh|hpp|hxx|kt|kts|sh|bash|css|scss|less)$'
emit_context() { # event, text
  jq -cn --arg e "$1" --arg t "$2" '{hookSpecificOutput:{hookEventName:$e, additionalContext:$t}}'
}
