# Oracle: classes implementing TypeVisitor

Derived without a language server: an exhaustive text candidate list over the whole repository at the pinned
commit, classified by hand, and cross-checked with a syntactic scan (TypeScript compiler API, no type checker) of
class heritage clauses.

    rg -n '\bTypeVisitor\b' .          # 11 lines outside CHANGELOG

- Direct (`implements o.TypeVisitor`): `AbstractEmitterVisitor` (compiler/src/output/abstract_emitter.ts:237; the
  clause is on line 238), `TypeTranslatorVisitor` (compiler-cli/.../type_translator.ts:39),
  `ExpressionTranslatorVisitor` (compiler-cli/.../translator.ts:85; clause on line 86).
- The other occurrences are the interface itself (output_ast.ts:109), parameter types of `visitType`
  (output_ast.ts:22-95) and a re-export (compiler/src/compiler.ts:121).
- Subclasses, searched level by level with `rg -n 'extends\s+(\w+\.)?<Name>\b'` until nothing new appeared:
  `AbstractJsEmitterVisitor extends AbstractEmitterVisitor` (abstract_js_emitter.ts:27);
  `JitEmitterVisitor extends AbstractJsEmitterVisitor` (output_jit.ts:107) and
  `TestJsEmitter extends AbstractJsEmitterVisitor` (compiler/test/output/abstract_emitter_spec.ts:13).
  Nothing extends `TypeTranslatorVisitor`, `ExpressionTranslatorVisitor`, `JitEmitterVisitor` or `TestJsEmitter`.
- No interface extends `TypeVisitor`.

Judgement calls: none (structural look-alikes are excluded by the prompt).
