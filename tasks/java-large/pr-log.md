# Mined pull requests: java-large (jackson-databind)

Modern pull requests (opened on or after 2026-07-01, merged, closing a linked issue; docs/MEMORIZATION.md).
`harness/gen/mine-prs.sh java-large` found 50 that qualify (the first 40 in `pr-candidates.jsonl`); the earlier
pre-2022 candidates and fallback tasks were removed (git history keeps them). Candidates were taken strictly in the
seeded order (seed 20261110). Fail-to-pass tests (`f2p.txt`) are the test classes the pull request adds or changes under
`src/test/java`; the pass-to-pass set is every test of the module (`mvn test`), JDK 21 and Maven 3.9.11. `hidden/`
holds the test files at the merge commit; `gold.patch` is the pull request's non-test change (`base_commit` to
`merge_commit`; it includes release-notes edits), used only by `./study validate`. The base commit is the merge
commit's first parent (squash merges), which can differ from the REST base sha of the pull request (`pr_base_sha`).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #6171 | Allow skipping null values for properties handled by `@JsonAnySetter` | task `pr-6171`, VALID; memorization probe worst verbatim share 0.01 |
| 2 | #6370 | NullPointerException deserializing raw `Map.Entry` with a `Shape.POJO` config override | task `pr-6370`, VALID; probe 0.08 |
| 3 | #6407 | `@JsonFormat(shape = ARRAY)` builder with `@JsonCreator` silently loses buffered property if builder is immutable | task `pr-6407`, VALID; probe 0.05 |
| 4 onward | | | not needed |
