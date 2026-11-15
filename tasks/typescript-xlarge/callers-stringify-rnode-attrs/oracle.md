# Oracle: exported functions of hydration/error_handling.ts that reach stringifyRNodeAttrs

Derived without a language server: a syntactic call graph of the file's top-level functions (TypeScript compiler
API parser, no type checker), then every edge checked by hand against

    grep -nE '\b(stringifyRNodeAttrs|describeRNode|describeDomFromNode|describeExpectedDom)\(' packages/core/src/hydration/error_handling.ts

- `stringifyRNodeAttrs` (line 273) is called only by `describeRNode` (line 323).
- `describeRNode` is called by `describeExpectedDom` (363), `describeDomFromNode` (381, 383, 388) and the exported
  `nodeNotFoundAtPathError` (191).
- `describeExpectedDom` is called by the exported `validateMatchingNode` (79), `validateNodeExists` (154) and
  `nodeNotFoundError` (176).
- `describeDomFromNode` is called by the exported `validateMatchingNode` (98), `validateSiblingNodeExists` (130),
  `unsupportedProjectionOfDomNodes` (213) and `invalidSkipHydrationHost` (230).

The eighth exported function, `describeDomNode` (line 500), calls none of them. The four functions on these paths
are not exported, not passed as values and not referenced outside the file
(`rg -n 'stringifyRNodeAttrs|describeRNode\b|describeDomFromNode' packages` finds only this file).

Judgement calls: none.
