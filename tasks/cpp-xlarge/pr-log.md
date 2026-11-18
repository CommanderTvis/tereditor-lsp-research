# Mined pull requests: cpp-xlarge (DuckDB)

`sh harness/gen/mine-prs.sh cpp-xlarge` keeps 85 pull requests (opened on or after 2026-07-01, merged into main, closing an issue, changing tests and C/C++ sources); `pr-candidates.jsonl` holds the first 60 in seeded order. The first three, strictly in order, built and validated.

| Candidate | Issue | Base commit | Test files | Outcome | Grade time (gold) |
| --- | --- | --- | --- | --- | --- |
| 27967 | 27966 | d5e42169812ce73ea8242a0a13eeea3e7ea7032f | test/common/test_http_transport_manager.cpp | taken: `pr-27967` (VALID) | 130 s |
| 28333 | 28211 | 6bb57d29dbc1f9032005816e6bb08763bd1a8fb2 | test/api/test_api.cpp, test/configs/force_storage_restart.json | taken: `pr-28333` (VALID) | 56 s |
| 27499 | 27458 | 0b272c23b19eb7747313fffa0a1097f720905b29 | test/sql/export/export_csv_empty_strings.test | taken: `pr-27499` (VALID) | 31 s |

`gold.patch` is GitHub's diff of the pull request without its test files, `hidden/` the test files at the pull request's head. `grade.sh` runs `check.sh` (incremental make of the unittest runner and the loadable test extension against the prebuilt build/ directory of the grading overlay) and then `run-task-tests.sh` (the changed .test file by path, or every TEST_CASE of the changed .cpp file). Each base commit needs its own cold `grade-setup.sh` build (about 17 to 21 minutes on 3 CPUs); the grade itself took 31 to 130 s. `memprobe.txt` holds the memorization probe (worst verbatim share 0.00 for all three).
