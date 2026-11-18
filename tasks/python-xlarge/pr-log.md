# Mined pull requests: python-xlarge (salt)

`sh harness/gen/mine-prs.sh python-xlarge`: 11 modern pull requests qualify (opened on or after 2026-07-01, merged, closing
an issue, tests plus source); all 11 are in `pr-candidates.jsonl`, taken in seeded order. Tests run with CPython 3.12 and
the requirements of `projects/python-xlarge/grade-setup.sh` (timelib omitted: no wheel, no compiler); `grade.sh` points the
sandbox at libstdc++ and OpenSSL by hand (no ldconfig).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #70173 | mounts.fstab output uses different name for same setting | task `pr-70173` (3 fail-to-pass, 25 pass-to-pass); memprobe KEEP, worst 0.00 |
| 2 | #70369 | Remove SyncWrapper and finish the move from tornado | skipped: no fail-to-pass test here (42 of 47 tests in its files are skipped without a running zeromq setup; the 4 that run fail after the merge, 1 passes both) |
| 3 | #70444 | scheduler trigger duplicate jobs due multimaster | task `pr-70444` (1 fail-to-pass, 68 pass-to-pass); memprobe KEEP, worst 0.00 |
| 4 | #69680 | Byte conversion factors off by power of 10 in _parse_numbers | task `pr-69680` (4 fail-to-pass, 21 pass-to-pass); see memprobe below |

Stopped at three accepted tasks; candidates 5 to 11 were not examined. The three placeholders `pr-*-fallback` were deleted.
