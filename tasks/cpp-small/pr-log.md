# Mined pull requests: cpp-small (MD4C)

`sh harness/gen/mine-prs.sh cpp-small` keeps 8 pull requests (opened on or after 2026-07-01, merged into master, closing an issue, changing tests and C sources). Candidates were taken strictly in the seeded order of `pr-candidates.jsonl`; three were accepted.

| Candidate | Issue | Base commit | Outcome |
| --- | --- | --- | --- |
| 388 | 365 | 3e7ace20d262028baf702db9850520f017c25591 | taken: `pr-388` (VALID) |
| 416 | 413 | 00788b157b2b6ef3efd8659b66f6521229f382d7 | taken: `pr-416` (VALID) |
| 421 | 380 | 10fa4f4410a58cdd03cb4de1ade6efbbe7de59a4 | skipped: does not validate. Its only test change is a new case in `test/pathological-tests.py` (an OSS-Fuzz input); the case passes at the base commit too, so there is no fail to pass |
| 439 | 435 | c8d7a7e8f68667d27b56fdfd15db6d3cd82272b2 | taken: `pr-439` (VALID) |

Not tried (three tasks reached): 446, 465, 418, 385.

Each task: `gold.patch` is the pull request's change to non-test files (merge base to head), `hidden/` its head's versions of the test files it changed, `grade.sh` runs `check.sh` (CMake build, then every suite through `scripts/run-tests.py`: spec, extension specs, regressions, coverage, pathological inputs). The grading toolchain's `python3` runs the suites. `memprobe.txt` holds the memorization probe (verbatim share 0.00 for every model on all three).
