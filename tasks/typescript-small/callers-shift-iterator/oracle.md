# Oracle: public entry points that reach shiftIterator

Derived without a language server: a static call graph of every top-level function and `Struct` method in `src/`,
built by a text script (bodies by indentation, calls as `name(` not preceded by `.`, `new Struct` as the
constructor, `.validate(`/`.assert(`/`.create(`/`.is(`/`.mask(` as the `Struct` methods), then every edge on the
paths below checked by hand against

    rg -n '(^|[^\w])(coerce|defaulted|trimmed|union|validate|is|assert|create|mask|shiftIterator)\s*(<[^()]*>)?\(' src

- `validate` (src/struct.ts:195) calls `shiftIterator`.
- `assert`, `create`, `mask`, `is` (src/struct.ts:128, 144, 162, 176) call `validate`.
- `Struct.assert`, `Struct.create`, `Struct.is`, `Struct.mask`, `Struct.validate` (src/struct.ts:68-115) call the
  functions of the same name.
- `coerce` (src/structs/coercions.ts:24) calls `is` inside its coercer closure; `defaulted` (:45) and `trimmed`
  (:80) call `coerce`.
- `union` (src/structs/types.ts:531) calls `S.validate(...)` on a `Struct` inside its coercer closure.

Nothing else calls `coerce`, `defaulted`, `trimmed`, `union`, `is`, `validate`, `assert`, `create` or `mask` in
`src/`. `Struct.constructor` reaches only `toFailures` (not `shiftIterator`); every struct factory reaches only the
constructor, `define`, `refine`, `print` and the object helpers, so none of them is included.

Judgement calls: none beyond the counting rules stated in the prompt (closures count; calls through stored struct
functions do not).
