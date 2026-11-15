In the `example` application, rename the source file
`example/src/main/kotlin/com/github/michaelbull/result/example/Application.kt` (the one with `fun main()`) to
`Main.kt` in the same directory. Keep its contents and package as they are. Anything that refers to the application's
entry point must follow the rename, so that the example still builds and `./gradlew :example:run` still launches it.
