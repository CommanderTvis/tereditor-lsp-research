# Oracle: accesses of EntityListenerMetadata.execute

Derived from the TypeScript compiler (typescript 5.9.3 from the project's lockfile), not a language server, by
mutation: the declaration at `packages/typeorm/src/metadata/EntityListenerMetadata.ts:81` was renamed to
`execute__studymut` and the package type-checked with its own configuration (src and test):

    cd packages/typeorm && tsc --noEmit --pretty false -p tsconfig.json

The result is exactly 11 errors, all TS2339 "Property 'execute' does not exist on type 'EntityListenerMetadata'",
at the lines of oracle.txt (all in `src/subscriber/Broadcaster.ts`); no other error, so nothing implements, overrides
or is checked against this member. A text cross-check (`rg -n '\.execute\('` in Broadcaster.ts gives the same 11
lines; every other `.execute(` in src and test is on a query builder, executor or other class).

Judgement calls: none.
