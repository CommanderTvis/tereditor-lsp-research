# Mined pull requests: java-small (quarkus-http-problem)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 14 that
qualify (closing issue, tests plus source); candidates were taken strictly in seeded order (seed 20261110). Fail-to-pass
tests (`f2p.txt`) are the test classes the pull request adds or changes under `src/test` whose names end in Test (the
`*IT` classes need the packaged application and are not run); the pass-to-pass set is every test of every module, run with
`-DskipSurefireTests=false` so the integration-test modules' @QuarkusTest classes are included. Built and tested with JDK 21
and Maven 3.10 (the project targets Java 17); hidden tests are the pull request head's versions of its test files.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #640 | not all Jackson exception mappers are overridden | task `pr-640`, VALID; memorization probe worst verbatim share 0.10 |
| 2 | #634 | improve error handling with malformed JSON | task `pr-634`, VALID; probe 0.00 (the pull request's merge base differs from the REST base sha, merge_base is recorded; base_commit is the base sha, no touched path differs between them) |
| 3 | #656 | fail the build when no JSON provider is detected | task `pr-656`, VALID; probe 0.00 |
| 4 onward | | | not needed |
