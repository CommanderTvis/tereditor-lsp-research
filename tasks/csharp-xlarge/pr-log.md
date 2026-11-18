# Mined pull requests: csharp-xlarge (linq2db)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 62 that
qualify (closing issue, tests plus source); 40 listed in seeded order (seed 20261110). The base commit of a task is the parent of
the pull request's squash-merge commit (the API's base.sha can be stale), `gold.patch` and the hidden tests are that commit's
diff (hidden test files = the base file plus the pull request's test diff). Tests run on the SQLite.MS provider only
(`--provider SQLite.MS`, no database server). Fail-to-pass tests (`f2p.txt`) are the test methods the pull request adds;
pass to pass is every test of the test classes it touched (`classes.txt`). F# test files are included in hidden/ but not built.

| Order | PR | Outcome |
| --- | --- | --- |
| 1 | #5844 | task `pr-5844` (compiled query with a SQL function and LoadWith), VALID; memprobe worst verbatim share 0.00 on 395 gold lines |
| 2 | #6107 | task `pr-6107` (F# option and union columns), VALID; 0.00 on 22 gold lines |
| 3 | #6146 | task `pr-6146` (SQLite string.Join over arithmetic items), VALID; 0.00 on 11 gold lines |

Results of the memorization probe are in each task's `memprobe.txt` (a measurement, not a filter). Environment notes:
the test project is built with `X86STUBS=True` (stubs for the x64-only DB2 and SAP HANA native client assemblies; without
them NUnit discovers 0 tests on arm64) and `check.sh` removes the ignored file `Data/Setup Scripts/UserDataProviders.json`
that the build writes, because the harness's overlay copy cannot handle its quoted path with a space.
