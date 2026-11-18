# Mined pull requests: kotlin-medium (kotlinpoet)

Modern pull requests (opened on or after 2026-07-01, merged, closing a linked issue; docs/MEMORIZATION.md).
`harness/gen/mine-prs.sh kotlin-medium` found 8 that qualify; the earlier pre-2022 candidates (all skipped for needing a
Gradle wrapper older than JDK 21 supports) and the fallback tasks were removed (git history keeps them). Candidates
were taken strictly in the seeded order of `pr-candidates.jsonl` (seed 20261110). The script's test-file pattern also
matches `FunSpec.kt`-style source names and `.../ksp/test/processor/` package paths; the tasks classify tests by
directory instead (`src/jvmTest`, `src/commonTest`, `src/test`, and the whole `interop/ksp/test-processor` module, which
holds the processor fixtures its tests use). Fail-to-pass tests (`f2p.txt`, one `<gradle task> <class>` per line) are the test
classes the pull request adds or changes; the pass-to-pass set is every test of the checked modules (`check.sh`: JVM
tests, Kotlin/JS and Wasm test compilation, JDK 21, Gradle wrapper of the base commit). `hidden/` holds the test files
at the merge commit; `gold.patch` is the pull request's non-test change (`base_commit` to `merge_commit`; it includes
`docs/changelog.md`), used only by `./study validate`. The base commit is the merge commit's first parent (squash
merges), which can differ from the REST base sha (`pr_base_sha`).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #2365 | Expression function runaway indentation | task `pr-2365`, VALID; memorization probe worst verbatim share 0.00 |
| 2 | #2368 | No TypeParameter found for index T | task `pr-2368`, VALID; probe 0.00 |
| 3 | #2406 | Support companion extensions | task `pr-2406`, VALID; probe 0.50 on a 2-line gold patch (derivable from the issue, the probe's cutoff check applies to 15 or more added lines) |
| 4 onward | | | not needed |
