# Oracle: Local API entry points that reach resolveValidationConcurrency

Derived without a language server: a static call graph of the top-level functions of packages/payload/src (text scan,
calls as `name(` not preceded by `.`), then a backward search from the target with `git grep -nP` for every function of
the chain, every caller checked by hand:

- `resolveValidationConcurrency` is called by `runLocaleScopedValidation` (utilities/runLocaleScopedValidation.ts:76).
- `runLocaleScopedValidation` is called by `validateLocalInternal` (collections/operations/local/validate.ts:148) and
  `validateGlobalLocalInternal` (globals/operations/local/validate.ts:105), both private to those files.
- Those are called by `validateLocal`, `validateLocalWithLocaleKeyedData` (collections) and `validateGlobalLocal`,
  `validateGlobalLocalWithLocaleKeyedData` (globals): four entry points.
- `validateLocalWithLocaleKeyedData` is also called by `createOperation` (collections/operations/create.ts:471) and by
  `updateDocument` (collections/operations/utilities/update.ts:422); `validateGlobalLocalWithLocaleKeyedData` by the
  global `updateOperation` (globals/operations/update.ts:473).
- `createOperation` is called by `createLocal` (:221) and `duplicateOperation`, which `duplicateLocal` calls (:133);
  `updateDocument` is called by `renameFileOperation` (called by `renameFileLocal`, :39), by the collection
  `updateOperation` and `updateByIDOperation` (both called by `updateLocal`, :283 and :280); the global
  `updateOperation` is called by `updateGlobalLocal` (:130).
- Other callers (REST handlers under endpoints/, GraphQL resolvers in packages/graphql, `BasePayload` methods in
  src/index.ts) are not entry points under the prompt's rules and extend no chain.

Judgement calls: the exclusion of handlers, resolvers and class methods is stated in the prompt.
