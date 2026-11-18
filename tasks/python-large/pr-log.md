# Mined pull requests: python-large (mypy)

`sh harness/gen/mine-prs.sh python-large`: 97 modern pull requests qualify (opened on or after 2026-07-01, merged, closing
an issue, tests plus source); the 40 first in seeded order are in `pr-candidates.jsonl`. Taken strictly in that order.
Each was run with CPython 3.12 and `projects/python-large/grade-setup.sh` at its base commit: the PR's test files applied
(must fail), then with its non-test change (must pass), one test at a time (`-n0`) through the matching mypy or mypyc
test runner.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #22143 | `.real` and `.imag` on complex, float, int and bool values | task `pr-22143` (3 fail-to-pass, 34 pass-to-pass; mypyc `irbuild-*.test`); memprobe KEEP, worst verbatim share 0.19 (Opus) |
| 2 | #22239 | stubtest doesn't expand `**kwargs: Unpack[...]` in overloads | task `pr-22239` (1 fail-to-pass, 69 pass-to-pass); memprobe KEEP, worst 0.00 |
| 3 | #22007 | Overloaded function as a subtype of function with union type | task `pr-22007` (2 fail-to-pass, 270 pass-to-pass; `check-overloading.test`); memprobe KEEP, worst 0.00 |

Stopped at three accepted tasks; no candidate was dropped. Candidates 4 to 40 were not examined.
