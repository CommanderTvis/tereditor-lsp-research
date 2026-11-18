# Mined pull requests: java-kotlin-medium (pact-jvm)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 8 that
qualify (closing issue, tests plus source: the marginal case named in the replacement brief); candidates taken strictly in
seeded order (seed 20261110). Their tests are Spock specifications (Groovy); fail-to-pass tests (`f2p.txt`) are the
specification classes the pull request adds or changes, one line per class as "<gradle project path> <class>"; the
pass-to-pass set is every test of core:support, core:pactbroker, core:model, core:matchers, consumer and provider, with
consumer's MockHttpServerSpec left out (it fails in the sandbox at every commit, `grade-exclude.gradle`). Modules that need
native libraries or services (pact-jvm-server, compatibility-suite, provider:lein, the Spring and Maven/Gradle plugin
modules) are not built by check.sh. Built with JDK 21 and Gradle 8.12.1 (the wrapper); the cold run of the whole test set
took about 3 to 4 minutes on 3 CPUs.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #1936 | custom HTTP headers not passed in all provider calls | task `pr-1936`, VALID; memorization probe worst verbatim share 0.02 |
| 2 | #1939 | V4Pact.mergeInteractions drops metadata.plugins | task `pr-1939`, VALID; probe 0.03 |
| 3 | #1945 | eachValue rules below the path not applied | task `pr-1945`, VALID; probe 0.08 |
| 4 to 8 | #1946, #1947, #1948, #1942, #1934 | | not needed |
