# Mined pull requests: php-large (laravel/framework)

`harness/gen/mine-prs.sh` (opened on or after 2026-07-01, merged, default branch 13.x, closing issue, tests plus source): 38
candidates in `pr-candidates.jsonl`, taken in its seeded order. Each candidate's task directory was built, memorization-probed
(`python3 harness/memprobe/memprobe.py`, all three models), and built and validated only if the probe passed. Dependencies per
base commit: `projects/php-large/locks/` (resolved for PHP 8.4) and a matching case in `prepare.sh`. Gold patch and hidden tests
come from `gh pr diff` (gold: the .php files outside tests/; hidden: the test files after the pull request).

| # | PR | Merged | Outcome |
| --- | --- | --- | --- |
| 1 | #61454 | 2026-09-06 | taken: `pr-61454`, VALID; memprobe SCORE worst verbatim share 1.00 (2-line fix; a measurement, not a filter) |
| 2 | #61659 | 2026-09-21 | taken: `pr-61659`, VALID; worst verbatim share 0.00 (all three models) |
| 3 | #61610 | 2026-09-16 | taken: `pr-61610`, VALID; worst verbatim share 0.00 |
| 4 | #60931 | 2026-07-30 | not taken: the first 3 candidates in seeded order that validate are 61454, 61659, 61610 (60931 had built and validated, SCORE 0.23) |

The probe ran over the candidates in the seeded order and stopped after three keepers. Candidates 6 to 38 were not examined.
Code lines at the base commits (scc 3.5.0, PHP, vendor/ excluded, tests included): 124k to 128k.
