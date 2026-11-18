# Mined pull requests: csharp-large (Jellyfin)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 31 that
qualify (closing issue, tests plus source); candidates taken in seeded order (seed 20261110). Fail-to-pass tests
(`f2p.txt`) are the test methods the pull request adds; pass to pass is every test of the pull request's test project(s)
(`TEST_PROJECTS` in each `grade.sh`).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #17524 | special features of multi-version episodes | task `pr-17524`, VALID; memorization probe KEEP (worst verbatim share 0.00) |
| 2 | #17643 | session creation leaks orphaned rows | task `pr-17643`, VALID; probe KEEP (0.00) |
| 3 | #17636 | WEB-DL tag stays in search title | task `pr-17636`, VALID; probe KEEP (0.00) |
| 4 | #17281 | non-UTF-8 subtitles | built and VALID, not needed (3 accepted); removed |

Environment notes: `check.sh` leaves Jellyfin.Drawing.Skia.Tests (native SkiaSharp fails on an unchanged tree) and
Jellyfin.Networking.Tests (resolves jellyfin.org) out of its default test list.
