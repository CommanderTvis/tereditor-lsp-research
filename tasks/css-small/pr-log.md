# Mined pull requests: css-small (tabler)

`sh harness/gen/mine-prs.sh css-small`: 14 modern pull requests qualify (opened on or after 2026-07-01, merged, closing an issue,
tests plus Sass source), taken strictly in the order of `pr-candidates.jsonl`; only pull requests whose tests are SCSS-level
(the sass-true and compile tests of `core/scss/tests`, run by vitest) can be graded here, the browser-mode JavaScript tests
cannot. Tabler merges by squash, so the base commit of a task is the parent of the merge commit (the REST `base.sha` is
stored as `rest_base_sha`); `gold.patch` is the pull request's change to the non-test files, hidden tests are the post-merge
versions of the test files and snapshots it changed. Each was run in the grading sandbox with the repository's vitest SCSS
configuration (pnpm install without scripts, `grade-setup.sh`): its test files applied to the base commit, then with its
non-test change.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #2848 | dropstart dropdown caret renders on the wrong side | task `pr-2848` (112 fail-to-pass, 0 pass-to-pass; `scss/tests/scss.test.mjs`) |
| 2 | #2751 | Caret size in docs nav links rather small after recent commits | task `pr-2751` (2 fail-to-pass, 108 pass-to-pass; `scss/tests/scss.test.mjs`) |
| 3 | #3111 | [BUG] Validation states in input-group-flat broken with input-group-text | task `pr-3111` (6 fail-to-pass, 0 pass-to-pass; `scss/tests/input-group-flat.test.mjs`) |

Stopped at three accepted tasks. #2848 changes `.test.scss` files that the single aggregating test file `scss.test.mjs`
compiles, so at the base commit that file does not run at all (all 112 of its tests are fail to pass); #3111 adds a new test file.
The memorization probe is a measurement (`memprobe.txt` in each task).
