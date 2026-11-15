Rename the extension function `Iterable<Result<V, E>>.filterErr()` (declared in
`kotlin-result/src/commonMain/kotlin/com/github/michaelbull/result/Iterable.kt`) to `collectErr`, everywhere it is
declared or used: library code, tests, and the deprecation messages and replacement hints that point to it. Do not keep
the old name as an alias.

The `Flow` extension `filterErr()` in `kotlin-result-coroutines` is a different function and keeps its name; its
callers must keep working. Updating the README is optional.
