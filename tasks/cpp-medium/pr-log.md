# Mined pull requests: cpp-medium ({fmt})

`sh harness/gen/mine-prs.sh cpp-medium` keeps 9 pull requests (opened on or after 2026-07-01, merged into main, closing an issue, changing tests and sources). Candidates were taken strictly in the seeded order of `pr-candidates.jsonl`; the first three built and validated.

| Candidate | Issue | Base commit | Test program | Outcome |
| --- | --- | --- | --- | --- |
| 4896 | 4851 | e76a9520a3c339d2cb6a1510db43a05ea9bd8ae6 | format-test | taken: `pr-4896` (VALID) |
| 4902 | 4901 | b039e624c02ae473280156235217f9e02792b055 | format-test | taken: `pr-4902` (VALID) |
| 4962 | 4961 | 5da4e9a3 (see task.toml) | ranges-test | taken: `pr-4962` (VALID) |

Each task: `gold.patch` is the pull request's diff to non-test files, `hidden/` its head's version of the test file, `grade.sh` builds the test programs of the changed files with the CMake build (Debug, `CMAKE_POLICY_VERSION_MINIMUM=3.5`) and runs them through ctest. `memprobe.txt` holds the memorization probe (worst verbatim share 0.00, 0.00, 0.01).
