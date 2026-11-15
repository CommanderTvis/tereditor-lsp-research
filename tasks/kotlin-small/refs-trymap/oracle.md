# Oracle: uses of the `Result<Iterable<V>, E>.tryMap` overload (Map.kt:291)

Derived with the Kotlin compiler through the build, not a language server: `derive-oracle.sh`, run in the grading
sandbox (offline) on a fresh copy of the snapshot.

1. Pass 1: the declaration is annotated `@Deprecated("STUDY_ORACLE", level = WARNING)` and every JVM compilation of
   every module is rebuilt (`:kotlin-result:compileTestKotlinJvm`, `:kotlin-result-coroutines:compileTestKotlinJvm`,
   `:benchmarks:compileKotlinJvm`, `:example:compileKotlin`; common code is compiled as part of the JVM compilations).
   0 errors; 4 STUDY_ORACLE warnings.
2. Pass 2: the declaration is renamed and `:kotlin-result:compileKotlinJvm` rebuilt: 4 errors, all at
   `Deprecated.kt:122:12` (no applicable `tryMap` candidate because of the receiver type); the module compiled with
   0 errors before.
3. Union as `path:line`: 4 uses in 2 files.

Cross-check against the exhaustive text candidates (`rg -nw tryMap -g '*.kt' -g '*.kts'`, 16 lines), each classified:

- Kept: `Deprecated.kt:122` (`mapAll`, receiver `Result<Iterable<V>, E>`), `MapTest.kt:364`, `:374`, `:390`.
- Dropped: `Map.kt:291` (the declaration); `Map.kt:293` and `Deprecated.kt:48` (receiver `Iterable<V>`: the other
  overload); `Deprecated.kt:44`, `:120` (strings in `@Deprecated`); `Try.kt:464` (the `Iterable` overload's
  declaration); `TryTest.kt:886`, `:896` (calls on lists); coroutines `flow/Try.kt:73` (KDoc), `:78` (the `Flow`
  overload's declaration); coroutines `flow/TryTest.kt:85`, `:96` (calls on flows).

Platform source sets (jsMain, nativeMain, wasmJsMain, jvmMain) contain no `tryMap`. Judgement calls: none.
