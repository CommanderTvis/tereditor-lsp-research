# Mined pull requests: java-kotlin-large (embabel/embabel-agent)

Modern pull requests (opened on or after 2026-07-01, merged, closing a linked issue, not by a bot; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh java-kotlin-large` found 99 that qualify (the first 40 in `pr-candidates.jsonl`). Candidates were taken strictly in the seeded order (seed 20261110). The base commit is the first parent of the merge commit (squash merges). `hidden/` holds the pull request's test files at the merge commit; `gold.patch` is its non-test change (instruction files that the snapshot strips are left out), used only by `./study validate`. The fail-to-pass set (`f2p.txt`) is every test class in the changed test files; the pass-to-pass set is every test of the modules those tests live in.

Tests that need Docker (Testcontainers) are skipped by the project's own switch (`SKIP_TESTCONTAINER_TESTS=true`, set by `check.sh`). The build and test run covers the modules the pull request's tests live in and the modules they depend on (`-pl <modules> -am`).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #1989 | Sub-Issue: Snapshot/Restore Foundation For HITL Persistence | skipped: the pull request adds test dependencies (spring-data-jdbc 4.1.1, h2 2.4.240) to `embabel-agent-api/pom.xml` that the base commit's build has never resolved, so the reference solution cannot be built offline in the sandbox |
| 2 | #2138 | ObservabilityTool tags a returned Tool.Result.Error as success | task `pr-2138`, VALID; memorization probe worst verbatim share 0.20 on a 15-line patch (the cutoff check flags the issue text as sufficient to derive it) |
| 3 | #1894 | LLM roles should resolve through an SPI to a materialized LlmService | task `pr-1894`, VALID; probe 0.03 |
| 4 | #1893 | Prompt assembly costs 300ms on every LLM call, and none of it is attributed | task `pr-1893`, VALID; probe 0.03 (its tests include a timing test, `PromptAssemblyPerformanceTest`) |
| 5 onward | | | not needed |
