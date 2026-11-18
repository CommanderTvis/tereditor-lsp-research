# Oracle: which of ten DuckDB files declare a variable that shadows a local of an enclosing scope

Derived with clang, not a language server: `derive-oracle.sh` (Apple clang 21 on the host, `clang -fsyntax-only -Wno-everything -Wshadow` with the flags of the build's compile_commands.json, cmake `-DDISABLE_UNITY=1`). A file is a positive if clang reports "declaration shadows a local variable" at a location in the file itself that does not come from a macro expansion.

Positives (report locations, from `shadow-reports.txt` of the run):

- `src/function/cast/vector_cast_helpers.cpp:573`
- `src/function/function_binder.cpp:373`
- `src/function/table/arrow/arrow_duck_schema.cpp:272`
- `src/function/table/arrow/arrow_duck_schema.cpp:289`
- `src/main/capi/v1/result-c.cpp:137`
- `src/planner/binder/tableref/bind_expressionlistref.cpp:158`

Decoys (no report at all): `src/common/types/vector_cache.cpp`, `src/execution/operator/helper/physical_verify_vector.cpp`, `src/common/types/vector.cpp`, `src/parser/peg/transformer/transform_deallocate.cpp`, `src/function/scalar/compressed_materialization/compress_integral.cpp`.

Judgement calls: the compile is the macOS host's, so code under `#ifdef _WIN32` or other platform branches is not seen. The ten files were re-checked on Linux with the grading toolchain's gcc 14 (`g++ -fsyntax-only -Wshadow=local` with the build's include paths): the five decoys report nothing and each positive reports at the same line (`vector_cast_helpers.cpp:573`, `function_binder.cpp:373`, `arrow_duck_schema.cpp:272`, `result-c.cpp:137`, `bind_expressionlistref.cpp:158`). Files whose only reports come from macro expansions were excluded from both pools.
