# Mined pull requests: csharp-small (MediatR)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 5 that
qualify (closing issue, tests plus source); candidates taken in seeded order (seed 20261110). Fail-to-pass tests (`f2p.txt`)
are the test methods the pull request adds (fragments matched with `FullyQualifiedName~`); the whole test project is the
pass to pass set. Built and tested with the study toolchain (.NET SDK 10), rolled forward as for all C# projects.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #1186 | constraint inference: chained constraints | task `pr-1186`, VALID; memorization probe KEEP (worst verbatim share 0.00) |
| 2 | #1187 | strip whitespace from the license key | task `pr-1187`, VALID; probe KEEP (0.00) |
| 3 | #1192 | license key configuration | task `pr-1192`, VALID (revalidated after a whitespace-tolerant patch apply, harness/grade/grade.sh); probe KEEP (0.00) |
| 4, 5 | #1197, #1184 | | not needed (3 accepted; #1197 validated, #1184 adds a new test project the check does not build) |
