# Mined pull requests: kotlin-large (Kotlin/dataframe)

Modern pull requests (opened on or after 2026-07-01, merged, closing a linked issue, not by a bot; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh kotlin-large` found 62 that qualify (the first 40 in `pr-candidates.jsonl`). Candidates were taken strictly in the seeded order (seed 20261110). The base commit is the first parent of the merge commit (squash merges). `hidden/` holds the pull request's test files at the merge commit; `gold.patch` is its non-test change (instruction files that the snapshot strips are left out), used only by `./study validate`. The fail-to-pass set (`f2p.txt`) is every test class in the changed test files; the pass-to-pass set is every test of the modules those tests live in.

The pass-to-pass set excludes the tests listed in each task's `p2p-exclude.txt`: the samples `Schemas.useInferredSchema` and the `QuickStartGuide` class read from the network, which the sandbox lacks, and fail for any patch (taken from a run of the reference solution).

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #2056 | toJson() drops row objects when a real "value" column contains only nulls | task `pr-2056`, VALID; memorization probe worst verbatim share 0.00 |
| 2 | #2176 | Make GroupBy.sortBy and sortByDesc sort rows within groups only | task `pr-2176`, VALID; probe 0.00 |
| 3 | #2190 | Add column selector overload to GroupBy.sortByKey | task `pr-2190`, VALID; probe 0.01 |
| 4 onward | | | not needed |
