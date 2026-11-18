# Mined pull requests: shell-small (bats-core)

`sh harness/gen/mine-prs.sh shell-small`: 8 modern pull requests qualify (opened on or after 2026-07-01, merged, closing an
issue, tests plus source), taken strictly in the order of `pr-candidates.jsonl`. Each was run in the grading sandbox
(bats from the work tree, the test files the pull request changed, bash and bats of `grade-shell`): its test files applied
to the base commit (must fail), then with its non-test change (must pass).

The base commit of a task is the fork point of the pull request (the merge base of the merge commit's parents; for #1212,
which was opened on the parent of #1211 and merged after it, the REST `base.sha` of the pull request, `2c6cde7`, is stored
as `rest_base_sha` and the fork point is the merge of #1211). Hidden tests are the pull request head's version of the
changed test files; `gold.patch` is the head's non-test change against the fork point.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #1212 | bats exits zero when first argument is empty string | task `pr-1212` (1 fail-to-pass, 125 pass-to-pass; `test/bats.bats`) |
| 2 | #1220 | Formatter "pretty" is not the default anymore in version 1.14.0 | skipped: its only new test that fails at the base commit, "default formatter in interactive shell is interactive pretty", needs `script` (util-linux), which `grade-shell` does not contain, so it fails with the reference change too; the other new tests pass at the base commit, so the pull request has no fail-to-pass test in this toolchain (nix/flake.nix would need `util-linux` in `grade.shell`) |
| 3 | #1240 | --allow-empty-suite forces a hard dependency on bats >= 1.14 | task `pr-1240` (4 fail-to-pass, 150 pass-to-pass; `test/bats.bats`, `test/suite.bats`) |
| 4 | #1249 | `bats_test_function` false "Duplicate test name(s)" when one dynamic test's args are a prefix of another's | task `pr-1249` (4 fail-to-pass, 142 pass-to-pass; `test/bats.bats`) |

Stopped at three accepted tasks. The memorization probe is a measurement (`memprobe.txt` in each task).
