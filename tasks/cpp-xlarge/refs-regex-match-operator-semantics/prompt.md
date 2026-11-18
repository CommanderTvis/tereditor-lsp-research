We are reviewing where DuckDB's `RegexMatchOperatorSemantics` enum (the `PARTIAL`/`FULL` switch for the regex match operator) is used. List every place in the C++ sources under `src/`, `extension/`, `tools/` and `test/` where the type name `RegexMatchOperatorSemantics` is used as code: as a type, in a template argument, in a cast, or as the qualifier of an enumerator.

Do not count the enum's own declarations (its definition and its forward declaration), comments, or occurrences inside string literals or in JSON or other non-C++ files. If a line uses the name more than once it counts once.

Write the result to `ANSWER.txt` in the repository root, one `relative/path:line` per line (1-based line number).
