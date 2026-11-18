# Mined pull requests: java-medium (gson)

Modern pull requests (opened on or after 2026-07-01, merged, closing a linked issue; docs/MEMORIZATION.md).
`harness/gen/mine-prs.sh java-medium` found 8 that qualify; the earlier pre-2022 candidates and fallback tasks were
removed (git history keeps them). Candidates were taken strictly in the seeded order of `pr-candidates.jsonl` (seed
20261110). Fail-to-pass tests (`f2p.txt`) are the test classes the pull request adds or changes under `src/test/java`;
the pass-to-pass set is every test of the `gson` and `proto` modules (`-pl gson,proto -am`), JDK 21 and Maven 3.9.11.
`hidden/` holds the test files at the merge commit; `gold.patch` is the pull request's non-test change
(`base_commit` to `merge_commit`), used only by `./study validate`. The base commit is the merge commit's first
parent (the pull requests were squash-merged), which can differ from the REST base sha of the pull request
(`pr_base_sha`): the squashed change applies cleanly only to the former.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #3059 | JsonPrimitive with LazilyParsedNumber integers breaks contract for hashCode() | task `pr-3059`, VALID; memorization probe worst verbatim share 0.12 |
| 2 | #3061 | Get JsonObject from google.protobuf.Struct | task `pr-3061`, VALID; the change adds `protobuf-java-util` as a test dependency of `proto`, so `grade-setup.sh` pre-fetches that artifact for offline grading; the issue is a feature request that does not name the new class (`StructTypeAdapter`) the pull request's tests use; kept (weak specification is not a reason to drop); probe 0.16 |
| 3 | #3098 | JsonReader / JsonTreeReader.promoteNameToValue() causes incorrect JSON path | task `pr-3098`, VALID; probe 0.18 |
| 4 onward | | | not needed |
