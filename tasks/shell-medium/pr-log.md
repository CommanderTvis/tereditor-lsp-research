# Mined pull requests: shell-medium (nvm)

`sh harness/gen/mine-prs.sh shell-medium`: 14 modern pull requests qualify (opened on or after 2026-07-01, merged, closing an issue,
tests plus source), taken strictly in the order of `pr-candidates.jsonl`. nvm merges by squash, so the base commit of a task is
the parent of the merge commit (the REST `base.sha` is stored as `rest_base_sha`); `gold.patch` is the pull request's change to
the non-test files, hidden tests are the post-merge versions of the test files it changed (urchin tests are executable files;
the mode is kept). Each was run in the grading sandbox: every test file of the directories its tests live in (project's
`run-tests.sh`, urchin's way, with bash), first at the base commit with the held-out tests, then with its non-test change;
fail to pass = fails first and passes then, pass to pass = passes both times.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #3907 | nvm_err fails when stderr is closed | task `pr-3907` (2 fail-to-pass, 111 pass-to-pass; `nvm_err, nvm_compare_checksum`) |
| 2 | #3891 | nvm v0.40.6 does not load the default node version in zsh if the option extended | task `pr-3891` (1 fail-to-pass, 113 pass-to-pass; `fast/Unit tests/nvm_print_alias_file, sourcing/Sourcing nvm.sh with zsh extendedglob should use the default`) |
| 3 | #3959 | previously used node version is not removed from the PATH variable | task `pr-3959` (1 fail-to-pass, 164 pass-to-pass; `fast/Unit tests/nvm_change_path`) |

Stopped at three accepted tasks. #3891 is a zsh bug whose zsh test cannot run here (the grading toolchain has bash only); its
fail-to-pass test is the bash-level unit test of `nvm_print_alias_file`. The memorization probe is a measurement
(`memprobe.txt` in each task).
