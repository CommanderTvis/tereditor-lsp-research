# Mined pull requests: csharp-medium (Spectre.Console)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 10 that
qualify (closing issue, tests plus source), taken in seeded order (seed 20261110). The base commit of a task is the parent
of the pull request's squash-merge commit (the API's base.sha was stale for some), `gold.patch` and the hidden tests are
that commit's diff (hidden test files = the base file plus the pull request's test diff). Fail-to-pass tests (`f2p.txt`) are
the test methods the pull request adds; pass to pass is the whole Spectre.Console.Tests project. Pull requests merged from
2026-11-17 on pin SDK 11: `check.sh` rewrites global.json to the installed SDK 11 and puts it first on PATH only for those.

| Order | PR | Outcome |
| --- | --- | --- |
| 1 | #2183 | task `pr-2183`, VALID; memprobe worst verbatim share 0.33 on 3 gold lines |
| 2 | #2212 | task `pr-2212`, VALID; 0.40 on 5 gold lines |
| 3 | #2219 | task `pr-2219`, VALID; 0.00 on 4 gold lines |

Memprobe results are in each task's `memprobe.txt` (a measurement, not a filter; the gold patches are 3 to 5 added lines, so
the cutoff check does not apply). 7 qualifying pull requests were not needed.
