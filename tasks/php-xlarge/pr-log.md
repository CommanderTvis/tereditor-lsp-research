# Mined pull requests: php-xlarge (shopware/shopware)

harness/gen/mine-prs.sh (opened on or after 2026-07-01, merged, closes an issue, tests plus source; default branch trunk): 134 qualify, 40
candidates in seeded order. Only tests/unit files are run (no MySQL); a pull request whose integration or JavaScript tests changed too still counts if its unit tests fail
before and pass after the change. Dependencies: projects/php-xlarge/locks (one lock per composer.json, PHP 8.4). Memorization probe: a measurement, memprobe.txt per task.

| PR | Merged | Outcome |
| --- | --- | --- |
| #22186 | 2026-10-29 | taken, VALID; worst verbatim share 0.07 |
| #20996 | 2026-10-01 | taken, VALID; worst verbatim share 0.38 (gold of 10 added lines) |
| #22487 | 2026-11-05 | taken, VALID; worst verbatim share 0.00 |

Stopped at 3 valid tasks; the 37 later candidates were not examined. Code lines at the base commits: about 1.08M (scc 3.5.0, pinned commit 1.10M).
