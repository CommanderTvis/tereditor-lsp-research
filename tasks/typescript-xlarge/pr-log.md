# Mined pull requests: typescript-xlarge (payloadcms/payload)

Modern rule (docs/MEMORIZATION.md): opened on or after 2026-07-01 and merged. 40 candidates listed by the miner (pr-candidates.jsonl,
seeded order, first 40 kept), taken strictly in order; the first three built and validated. The memorization probe is a
measurement (memprobe.txt in each task).

| PR | Outcome | Note |
| --- | --- | --- |
| 17441 | task pr-17441 | worst verbatim share 0.03; the Postgres-only spec (postgres-logs.int.spec.ts) is skipped under sqlite |
| 18585 | task pr-18585 | unit spec in packages/ui; worst share 0.00 |
| 19006 | task pr-19006 | worst share 0.20 |

Tests run through vitest on Node 24 with PAYLOAD_DATABASE=sqlite (libsql); grade.sh passes the specs the pull request
changed (end-to-end specs would be excluded: no browsers). grade_timeout_s = 1200 in each task.toml: a cold vitest run of
an int spec compiles a large part of the monorepo.
