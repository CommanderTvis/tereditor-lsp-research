I am adding a method to the `TypeVisitor` interface declared in `packages/compiler/src/output/output_ast.ts` and
need to know every class that will have to provide it.

List every class in this repository that implements `TypeVisitor`, either by naming it in its `implements` clause
(however the interface is imported or qualified) or by extending, directly or through further base classes, a class
that does. Include abstract classes and classes in test files. Do not include interfaces, classes that merely use a
`TypeVisitor`, or classes that only happen to have matching methods without declaring or inheriting the interface.

Write the result to `ANSWER.txt` in the repository root, one class per line as `relative/path.ts:LINE`, where LINE
is the 1-based line of the class declaration (the line containing `class ClassName`), for example
`packages/core/src/foo.ts:12`.
