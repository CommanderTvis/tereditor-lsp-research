# Mined pull requests: typescript-large (typeorm)

Modern rule (docs/MEMORIZATION.md): opened on or after 2026-07-01 and merged. 26 candidates qualify (pr-candidates.jsonl,
seeded order), taken strictly in order. Grading is offline on sql.js only (no database server, no native driver). The
memorization probe is a measurement, not a filter: each task's memprobe.jsonl is kept.

| PR | Outcome | Reason |
| --- | --- | --- |
| 12711 | task pr-12711 | |
| 12759 | task pr-12759 | |
| 12752 | skipped | test needs better-sqlite3 (native, unbuilt): passes at the base commit, cannot fail to pass |
| 12729 | skipped | webpack test passes at the base commit: cannot fail to pass offline |
| 12704 | skipped | test needs better-sqlite3 (native, unbuilt): fails with and without the fix |
| 12891 | skipped | cockroachdb only (not built) |
| 12905 | task pr-12905 | |

Also built and validated before the rule change, not among the first three, removed: 12663, 12793 (12938 and 12706 were
built and validated too and also not needed).
