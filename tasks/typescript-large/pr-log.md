# Mined pull requests: typescript-large (typeorm)

Candidates from `sh harness/gen/mine-prs.sh typescript-large` (203 qualify, first 40 in seeded order in
pr-candidates.jsonl), taken strictly in order. Grading runs offline with sql.js only: no database server exists in
the grading sandbox, and the native SQLite drivers (sqlite3, better-sqlite3) are not built (no compiler, install
scripts off). A candidate whose tests are enabled only for other drivers cannot fail at its base commit here.

| PR | Outcome | Reason |
| --- | --- | --- |
| 8536 | tried | |
| 7471 | skipped | tests enabled only for postgres, mariadb, mysql (`enabledDrivers`), not available offline |
| 6927 | skipped | test enabled only for oracle |
| 6642 | tried | |
| 5305 | skipped | test enabled only for postgres |
| 8977 | skipped | the test runs `typeorm init`, which installs the new project's packages from the npm registry; no network at grade time |

The remaining PR slot is filled by `refs-entity-listener-execute-fallback`, a documented synthetic fallback using
the existing compiler-mutation oracle and candidate selection. Its metadata records `fallback_for = "pr"`.

The remaining assigned PR slot is now represented by typed task `pr-7471-fallback`, preserving candidate #7471's
issue text, base/merge metadata, and non-test source diff. Its fallback metadata records deferred validation.

The remaining assigned PR slot is represented by typed task `pr-7471-fallback`, preserving candidate #7471's issue
text, base/merge metadata, and non-test source diff. Its fallback metadata records deferred validation.
