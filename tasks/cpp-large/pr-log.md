# Mined pull requests: cpp-large (Redis)

`sh harness/gen/mine-prs.sh cpp-large` keeps 29 pull requests (opened on or after 2026-07-01, merged into unstable, closing an issue, changing tests and C sources); `pr-candidates.jsonl` holds them in seeded order. All are graded by Redis's Tcl suites; `grade-cpp` now has `tclsh`, and `grade.sh` runs only the Tcl units of the changed test files (`tclsh tests/test_helper.tcl --single unit/X`; `./runtest` needs `which`, absent in the grader), after building the server (libc malloc, no TLS).

| Candidate | Issue | Tests | Outcome |
| --- | --- | --- | --- |
| 15545 | 15550 | tests/unit/bitfield.tcl | skipped: does not validate (the held-out test already passes at the base commit: the undefined behaviour it concerns is not observable in a plain -O1 build) |
| 15758 | 15745 | tests/unit/tls.tcl | skipped: does not validate (the TLS unit only runs with --tls and the build has no TLS, so it passes at the base commit) |
| 15699 | 15597 | tests/modules/keyspace_events.c, bitfield, info-keysizes, moduleapi/keyspace_events | taken: `pr-15699` (VALID) |
| 15587 | 15586 | tests/unit/type/list-4.tcl | taken: `pr-15587` (VALID) |
| 15499 | 15498 | tests/integration/replication-buffer.tcl | skipped: does not validate (the held-out test file raises a Tcl error when sourced; gold fails too) |
| 16026 | 16025 | tests/unit/hotkeys.tcl | taken: `pr-16026` (VALID) |

`memprobe.txt` in each task holds the memorization probe. `grade_timeout_s = 1200` (cold server build plus the Tcl unit).
