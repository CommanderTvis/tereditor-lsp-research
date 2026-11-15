`kotlin-result` has several functions named `tryMap`. I need every place in this repository where one of them,
the infix extension on `Result<Iterable<V>, E>` declared in
`kotlin-result/src/commonMain/kotlin/com/github/michaelbull/result/Map.kt`
(`public inline infix fun <V, E, U> Result<Iterable<V>, E>.tryMap(transform: (V) -> Result<U, E>): Result<List<U>, E>`), is used.

Count only uses in Kotlin code that call that overload. Do not include its declaration, the other `tryMap` functions
(the extension on `Iterable<V>`, the one on `Flow<V>` in `kotlin-result-coroutines`), comments, KDoc, string literals
or Markdown and text files.

Write the result to `ANSWER.txt` in the repository root, one use per line as `relative/path.kt:LINE` (1-based line of
the `tryMap` name), for example `kotlin-result/src/commonMain/kotlin/com/github/michaelbull/result/Foo.kt:12`.
