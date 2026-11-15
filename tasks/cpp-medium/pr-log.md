# Mined pull requests: cpp-medium ({fmt})

`sh harness/gen/mine-prs.sh cpp-medium` keeps no pull request: it requires `baseRefName` to be today's default branch,
`main`, and every pull request merged before 2022-11-30 went into `master` (the branch was renamed later; 789 of the
800 pull requests fetched have base `master`). `pr-candidates.jsonl` was written by a copy of the script that accepts
`master` when the default branch is `main` (otherwise identical, same seed): 22 pull requests qualify.

Candidates were tried strictly in the seeded order; the first six were built and validated together, and the first
three valid ones became tasks.

| Candidate | Issue | Base commit | Test programs | Outcome |
| --- | --- | --- | --- | --- |
| 1360 | 1353 | 96f91428c6ad2d19f1ce87ae160b78f52ed989fb | core-test, locale-test | taken: `pr-1360` |
| 2158 | 2156 | 835b910e7d758efdfdce9f23df1b190deb3373db | format-test | taken: `pr-2158` |
| 1837 | 1819 | c7e6d8afb06cec7b8244f963dc081daf7e70f7f6 | chrono-test | taken: `pr-1837` |
| 1390 | 1389 | d6eede9e085f0b36edcf0a2f6dff5f7875181019 | format-test | valid, not used (three tasks reached) |
| 974 | 968 | 7f7504b3f532c6cd7d6de405241f774df6b4b666 | format-impl-test | valid, not used (three tasks reached) |
| 2394 | 2302 | cfc05e05f08dc0b6fe619831c96f00ee27d99613 | color-test | valid, not used (three tasks reached) |

Each task: `gold.patch` is the pull request's change to non-test files (merge base to head), `hidden/` its head's
versions of the test files it changed, `grade.sh` configures the CMake build (`CMAKE_POLICY_VERSION_MINIMUM=3.5` so
CMake 4 accepts the older `cmake_minimum_required`), builds the test programs of those files and runs them through
ctest: the pull request's new tests fail to build or fail at the base commit (fail to pass), every other test of those
programs passes before and after (pass to pass).
