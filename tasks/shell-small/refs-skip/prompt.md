I need every place in this repository where the test helper `skip`, defined in `lib/bats-core/test_functions.bash`,
is called: in the library and the `libexec/` scripts, in the test suite (`test/*.bats`, `test/*.bash`) and in the
test fixtures under `test/fixtures/` (fixture files are real Bats files that the suite runs).

Do not include its definition, comments, string literals or test names that merely contain the word "skip"
(for example expected TAP output such as `ok 1 foo # skip`), documentation (`docs/`, `man/`, Markdown files), or
calls that run a different function named `skip` (the pretty formatter, `libexec/bats-core/bats-format-pretty`, has
its own).

Write the result to `ANSWER.txt` in the repository root, one call per line as `relative/path:LINE` (1-based line
number), for example `test/foo.bats:12`.
