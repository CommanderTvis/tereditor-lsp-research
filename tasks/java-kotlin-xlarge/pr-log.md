# Mined pull requests: java-kotlin-xlarge (gradle/gradle)

Slot skipped on grade time (projects/java-kotlin-xlarge/project.toml). The pull requests taken are the first three whose
tests are all unit-level (src/test), in seeded order of `pr-candidates.jsonl`: #39526, #39587, #39260 (memprobe saved, worst
verbatim share 0.00 for each); the next would be #39771 and #39482. Validation: #39260 INVALID (gold fails; the :native
test build did not work offline against that base), #39526 did not finish three grade runs in 109 minutes because its
pass-to-pass set is every test of :gradle-cli, :launcher and :logging; #39587 was not reached. The candidate file came
from a copy of `harness/gen/mine-prs.sh` with smaller GraphQL pages and retries (GitHub answered 502/504 on 100-item pages
for this repository); filters and seed are unchanged. The obsolete pre-2022 `pr-*` and fallback tasks and the placeholder
synthetic tasks were removed (git history keeps them).
