The private helper `stringifyRNodeAttrs` in `packages/core/src/hydration/error_handling.ts` is going to change the
text it produces, and I need to know which of that module's exported functions can end up calling it, directly or
through other functions of the module.

List every function exported from `packages/core/src/hydration/error_handling.ts` whose body calls
`stringifyRNodeAttrs`, or calls a function that (transitively) does. A call counts wherever it appears in the
function body, including inside conditions and template strings. Do not list private (non-exported) functions, and
do not list functions of other modules.

Write the result to `ANSWER.txt` in the repository root, one function name per line (the bare exported name, for
example `describeDomNode`).
