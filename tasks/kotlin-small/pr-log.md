# Mined pull requests: kotlin-small (compose-lints)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 9 that
qualify (closing issue, tests plus source); candidates taken strictly in seeded order (seed 20261110). Fail-to-pass tests
(`f2p.txt`) are the test classes the pull request changes (a Gradle `--tests` pattern each); the pass-to-pass set is every
test of the `compose-lint-checks` module. The build asks for a JDK 26 toolchain; an init script (`grade-toolchain.gradle`)
selects the sandbox's JDK 21 (sources are compiled with --release 17 either way). The suite needs the default 8 GB sandbox:
with 4 GB a test worker dies. `grade_timeout_s = 1200` is set in every task because a cold run takes several minutes.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #617 | ComposeRedundantComposable false positive on composable lambda invocation | task `pr-617`, VALID; memorization probe worst verbatim share 0.00 |
| 2 | #622 | suggest NonRestartableComposable on pass-through composables | task `pr-622`, VALID; probe 0.13 |
| 3 | #624 | ComposeReadOnlyComposable false negative on read in default argument | task `pr-624`, VALID; probe 0.00 |
| 4 onward | | | not needed |
