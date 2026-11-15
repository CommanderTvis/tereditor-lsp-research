# Mined pull requests: python-medium (rich)

`sh harness/gen/mine-prs.sh python-medium` finds 0 candidates: rich's default branch is `main` today, but every pull
request before the cutoff was merged into `master` (renamed later), and the script keeps only pull requests whose base
is the current default branch. The candidates were produced by the same script with the base branch set to `master`
(62 qualify, 40 written, same seed and order rule); the harness change is described in the curation report.

Taken strictly in the order of `pr-candidates.jsonl`, checked with CPython 3.12 and the pinned dependencies of
`projects/python-medium/grade-setup.sh`. Fail-to-pass = tests of the changed test files passing after the merge and not
at the base with the merged tests; pass-to-pass = passing both. Tests failing both before and after are in neither.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #1655 | #1515 Code-blocks end on line-breaks | skipped: needs an older Python. Its test (`tests/test_log.py::test_log`) fails after the merge on 3.12: the expected output contains `ColorSystem.TRUECOLOR`, the pre-3.12 format of a mixed-in enum; no fail-to-pass test |
| 2 | #2225 | #2206 Missing whitespace in traceback | skipped: no fail-to-pass test (every test of the merged `tests/test_traceback.py` that passes after also passes at the base; `test_guess_lexer_yaml_j2` fails both with Pygments 2.19.2) |
| 3 | #2339 | #2333 Console.show_cursor() clobbers cursor style on Windows | skipped: its tests (`tests/test_win32_console.py`) are Windows-only; none runs on Linux |
| 4 | #2330 | #2312 If `show_header=False` the next row will have the header border style | task `pr-2330` (1 fail-to-pass, 13 pass-to-pass) |
| 5 | #144 | #140 Request: do not use WT_SESSION to detect Windows Terminal | task `pr-144` (1 fail-to-pass: the new `tests/test_jupyter.py::test_jupyter`). Note: the test checks the Jupyter defaults the pull request also changed (width 93, truecolor), not the Windows detection the issue describes |
| 6 | #452 | #450 [REQUEST] Add max_length to RichHandler | task `pr-452` (1 fail-to-pass: `tests/test_log.py::test_justify`, 20 pass-to-pass; `test_log` fails both, as in #1655). Note: the fail-to-pass test checks `Console.log(justify=...)`, a side change of the pull request, not `max_length` |

Stopped at three valid tasks; candidates 7 to 40 were not used (7 and 8, #2002 and #2247, were triaged while
batching and would qualify).
