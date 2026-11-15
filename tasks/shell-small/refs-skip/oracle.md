# Oracle: calls of `skip` from lib/bats-core/test_functions.bash

Derived without a language server: an exhaustive candidate list, then a decision per line.

    grep -rnw skip bin lib libexec test contrib docker install.sh uninstall.sh shellcheck.sh .github   # 126 lines minus docs

Candidates in command position (start of a line, or after `||`, `&&`, `;`, `then`, `else`, `do`) were kept as calls;
every other line was read. Kept: 61 calls, all in `test/` (tests and fixtures) plus
`libexec/bats-core/bats-exec-test:335`, which runs inside bats-exec-test after it sources test_functions.bash, so it
calls this definition.

Dropped, with the reason:

- `lib/bats-core/test_functions.bash:461` the definition; its other lines are comments.
- `libexec/bats-core/bats-format-pretty:299` calls the formatter's own `skip` (defined at `:107` of that file, the
  only definition in the formatter's process); `:113` is a string.
- `@test "... skip ..."` names, expected TAP lines (`# skip`), `printf` formats in bats-format-tap and bats-exec-file,
  `exit_metadata=' # skip'`, `skip_line_regexpr`, comments in tracing.bash, common.bash, bats-gather-tests,
  bats-exec-file, bats-exec-test, test_helper.bash, parallel.bats.
- `test/suite.bats:244` is a fixture directory name.
- `man/`, `docs/`, `.codespellrc`: documentation and configuration.

Judgement calls: three calls follow a quoted argument and `||` (`test/parallel.bats:12`, `test/bats.bats:619`,
`test/bats.bats:753`) and were added by reading, not by the command-position pattern. Calls inside `setup()` or
`setup_file()` of fixtures count (they are calls of the same function).
