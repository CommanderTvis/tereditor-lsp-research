# Mined pull requests: python-medium (astroid)

`sh harness/gen/mine-prs.sh python-medium`: 33 modern pull requests qualify (opened on or after 2026-07-01, merged, closing
an issue, tests plus source). Taken strictly in the order of `pr-candidates.jsonl`; each was run with CPython 3.12 and the
test tools of `projects/python-medium/grade-setup.sh`: its test files applied to the base commit (must fail), then with its
non-test change (must pass).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #3241 | False positive unbalanced-tuple-unpacking when unpacking a ... | task `pr-3241` (1 fail-to-pass, 520 pass-to-pass) |
| 2 | #3311 | TypeError: Instance.__init__() missing 1 required positional argument | task `pr-3311` (1 fail-to-pass, 147 pass-to-pass) |
| 3 | #3302 | OverflowError: %c arg not in range(0x110000) with Formatter | task `pr-3302` (5 fail-to-pass, 488 pass-to-pass) |

Stopped at three accepted tasks. The memorization probe is a measurement (`memprobe.txt` in each task).
