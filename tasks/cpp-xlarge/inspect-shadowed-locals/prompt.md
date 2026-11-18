Code review request. We want to find functions where a variable declared in an inner block has the same name as a local variable or a parameter of an enclosing scope of the same function (the inner declaration shadows the outer one). Which of the following ten files contain at least one such declaration?

- `src/common/types/vector.cpp`
- `src/common/types/vector_cache.cpp`
- `src/execution/operator/helper/physical_verify_vector.cpp`
- `src/function/cast/vector_cast_helpers.cpp`
- `src/function/function_binder.cpp`
- `src/function/scalar/compressed_materialization/compress_integral.cpp`
- `src/function/table/arrow/arrow_duck_schema.cpp`
- `src/main/capi/v1/result-c.cpp`
- `src/parser/peg/transformer/transform_deallocate.cpp`
- `src/planner/binder/tableref/bind_expressionlistref.cpp`

Only declarations written in the file itself count: not ones that appear only through the expansion of a macro, and not ones in headers the file includes. Code in every `#if`/`#ifdef` branch counts. Shadowing of global variables, of members or of functions does not count.

Write the result to `ANSWER.txt` in the repository root, one path per line for each file that contains at least one such declaration, exactly as listed above (for example `src/foo.cpp`).
