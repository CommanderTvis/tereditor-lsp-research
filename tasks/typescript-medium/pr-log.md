# Mined pull requests: typescript-medium (hono)

Modern rule (docs/MEMORIZATION.md): opened on or after 2026-07-01 and merged. 39 candidates qualify (pr-candidates.jsonl,
seeded order); the first three that build and validate are the tasks. The memorization probe is a measurement, not a
filter: each task's memprobe.jsonl is kept.

| PR | Outcome |
| --- | --- |
| 5340 | task pr-5340 |
| 5423 | task pr-5423 |
| 5376 | task pr-5376 |

Candidates 5142 was also built and validated before the rule change; it is not among the first three and was removed.
grade.sh runs the test files the pull request changed through check.sh (type-check, then vitest on those files).
