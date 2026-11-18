# Mined pull requests: java-xlarge (apache/lucene)

`harness/gen/mine-prs.sh java-xlarge` found 28 modern pull requests (opened on or after 2026-07-01, merged, closing a
linked issue); candidates were taken strictly in the seeded order of `pr-candidates.jsonl` (seed 20261110). Their base
commits are on lucene main, whose build needs JDK 25 to 27; the `jvm` environments ship JDK 21 as the default and JDK 25
through `study-jdk25`, and the project's `prepare.sh`, `grade-setup.sh` and `check.sh` export `JAVA_HOME=$(study-jdk25)`.
Fail-to-pass tests (`f2p.txt`: module and class per line) are the test classes the pull request adds or changes under
`src/test`; the pass-to-pass set is every test of the module(s) they live in. `hidden/` holds the test files at the merge
commit (for #16684 also the two test-framework helper classes); `gold.patch` is the pull request's non-test change
(`base_commit`, the merge commit's first parent, to `merge_commit`), used only by `./study validate`.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #16547 | RangeBulkScorer calls collectRange with an empty range | task `pr-16547`, VALID; memorization probe worst verbatim share 0.67 on 3 gold lines (too short for the CUTOFF-CHECK rule, which needs 15 added lines) |
| 2 | #16706 | Improvements to the sandboxed de-duplicating vector format | task `pr-16706`, VALID; probe 0.00 |
| 3 | #16684 | Significant increase in IOPS during segment merge in Lucene 10 | task `pr-16684`, VALID; probe 0.00 |
| 4 onward | | | not needed |

The first trial run in this slot, on JDK 21 only, had skipped every candidate ("java version must be 25..26"); the earlier
pre-2022 fallback tasks were removed (git history keeps them). Each task's `memprobe.txt` holds the three models' lines.
