# The "optional" arm: remove headless SharpRail's advice to prefer its tools over other tools, so the tools are
# available but nothing urges them. Applied to every JSON-RPC line the server writes. Only the initialize instructions
# and three sentences of tool descriptions change; schemas, operations and results are untouched.
# Removed (SharpRail 95f7048):
#   initialize: "Use lsp_navigate instead of grep to find symbols, implementations and references, and lsp_diagnostics
#                to check edited files." and "For semantic changes (...) use ... instead of hand-editing; ..."
#   lsp_navigate:     "Use it instead of grep for code: it finds implementations, overloads, partial classes and
#                      generated code that text search misses."
#   lsp_code_actions: "Prefer them over hand-editing for semantic changes."
#   lsp_rename:       "Prefer it over search and replace."
def strip_advice:
  [ splits("(?<=[.!?])\\s+")
    | select((startswith("Use it instead of grep") or startswith("Use lsp_navigate instead of grep") or startswith("For semantic changes") or startswith("Prefer them over hand-editing")
              or startswith("Prefer it over search and replace")) | not) ]
  | join(" ");
if (.result? | type) == "object" and (.result | has("instructions")) then .result.instructions |= strip_advice
elif (.result?.tools? | type) == "array" then .result.tools |= map(.description |= (if type == "string" then strip_advice else . end))
else . end
