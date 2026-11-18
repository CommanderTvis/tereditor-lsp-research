The Kotlin file `compose-lint-checks/src/main/java/slack/lint/compose/util/KtFunctions.kt` holds extension functions on
Kotlin and Java methods, like its neighbours. We want its name to say that: rename the file to `KtFunctionsExt.kt`
(same directory).

Update everything that refers to the file by its path or name: configuration files, lists, documentation. The functions
in it keep their names and packages, so no Kotlin import changes. No file named `KtFunctions.kt` may remain, and the module
must still build and the existing tests must pass.
