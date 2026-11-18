# Oracle: calls of `returnsUnitOrVoid(UMethod)` (compose-lints 1.6.1)

Derived without a language server, from the compiler: the text candidates are every non-import, non-declaration
occurrence of `returnsUnitOrVoid` in the repository (`rg -n 'returnsUnitOrVoid' --glob '*.kt'`: 8 call lines in 6 main
files, none in tests, plus 7 import lines and the 2 declarations). `UMethod` is a subtype of `PsiMethod`, so renaming the
`UMethod` overload alone proves nothing (its calls would silently resolve to the `PsiMethod` overload and still compile).
Instead the `internal` `PsiMethod` overload (KtFunctions.kt:24) was renamed to `returnsUnitOrVoidPsiMutated` and the module
compiled (Kotlin 2.4.20, `:compose-lint-checks:compileKotlin :compose-lint-checks:compileTestKotlin --continue`): the only
error is at NonRestartableComposableDetector.kt:91 ("Candidate 'fun UMethod.returnsUnitOrVoid(...)' is inapplicable because
of a receiver type mismatch"), i.e. the only call that needs the `PsiMethod` version. Every other call line compiles
without it, so it has a `UMethod` receiver and resolves to the `UMethod` overload (the most specific one when both exist).
Answer = the 8 text call lines minus that one = 7 locations.

Judgement calls: none; import directives are excluded because one import covers both overloads.
