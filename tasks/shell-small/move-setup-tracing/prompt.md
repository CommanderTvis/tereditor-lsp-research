Move the function `bats_setup_tracing` out of `lib/bats-core/tracing.bash` into a new library file,
`lib/bats-core/setup_tracing.bash`, in the same directory as the other libraries. After the change:

- `bats_setup_tracing` is defined only in `lib/bats-core/setup_tracing.bash`;
- `lib/bats-core/tracing.bash` neither defines it nor sources the new file: every script that calls
  `bats_setup_tracing` must load `setup_tracing.bash` itself;
- bats works exactly as before and its test suite (including its shellcheck test) still passes.

Do not change what the function does.
