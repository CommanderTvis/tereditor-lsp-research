# Mined pull requests: python-small (pydantic-extra-types)

`sh harness/gen/mine-prs.sh python-small`: 19 modern pull requests qualify (opened on or after 2026-07-01, merged, closing
an issue, tests plus source). Taken strictly in the order of `pr-candidates.jsonl`; each was run with CPython 3.12 and the
dependency versions of the repository's `uv.lock` (grade-setup.sh): its test files applied to the base commit (must
fail), then with its non-test change (must pass).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #409 | Unhandled validation error when parsing Color | task `pr-409` (6 fail-to-pass, 111 pass-to-pass; `test_types_color.py`, `test_ulid.py`) |
| 2 | #446 | PhoneNumberValidator with number_format='NATIONAL' drops the ... | task `pr-446` (6 fail-to-pass, 32 pass-to-pass) |
| 3 | #439 | Slashes get cut off in CronStr | task `pr-439` (1 fail-to-pass, 5 pass-to-pass) |

Stopped at three accepted tasks. The memorization probe is a measurement (`memprobe.txt` in each task): worst verbatim share
1.00 for #409 (a one-line gold patch), 0.00 for #446 and #439.
