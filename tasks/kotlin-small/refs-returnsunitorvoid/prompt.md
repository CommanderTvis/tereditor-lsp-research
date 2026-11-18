The helper `returnsUnitOrVoid` in `compose-lint-checks/src/main/java/slack/lint/compose/util/KtFunctions.kt` exists twice: as
an extension function on `UMethod` (the public one, declared first) and as an `internal` extension function on `PsiMethod`.
We want to change what the `UMethod` version does and need to know which code is affected.

List every place where the `UMethod` version is called: calls written `method.returnsUnitOrVoid(...)` or
`method?.returnsUnitOrVoid(...)`, in the main and test source sets, that the compiler resolves to the `UMethod`
extension. Do not include its declaration, import directives, comments, strings, or calls that resolve to the `PsiMethod`
version.

Write the result to `ANSWER.txt` in the repository root, one location per line as `relative/path.kt:LINE` (1-based
line number of the call), for example `compose-lint-checks/src/main/java/slack/lint/compose/Foo.kt:12`.
