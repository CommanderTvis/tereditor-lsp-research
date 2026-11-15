# Mined pull requests: cpp-large (redis)

`sh harness/gen/mine-prs.sh cpp-large`: 92 pull requests qualify, 40 candidates in seeded order in
`pr-candidates.jsonl`. No `pr` task is written: every candidate's tests are Redis's Tcl suites (`./runtest`,
`tests/**/*.tcl`), and the one candidate without a `.tcl` file (9612, `tests/modules/datatype2.c`) changes a test
module that only the Tcl suite `tests/unit/moduleapi/datatype2.tcl` loads. The grading toolchain `grade-cpp` (gcc,
cmake, make, pkg-config) has no `tclsh`, so no fail-to-pass test can run. This is a missing tool, not exhausted
candidates: the three `pr` places stay open (not back-filled with synthetic tasks) until `tcl` is added to
`grade-cpp` in `nix/flake.nix`.

| Candidate | Issue | Base commit | Tests | Outcome |
| --- | --- | --- | --- | --- |
| 10160 | 9993 | 6ca97da0fcea4c260e656c3a05b12c34e5a4d63d | tests/integration/replication-4.tcl | skipped: Tcl test, no tclsh in grade-cpp |
| 10837 | 10833 | 9e40b076dd570cd7ecf27e1e8a6ca8d7fabf2302 | tests/modules/keyspecs.c, tests/unit/introspection-2.tcl, tests/unit/moduleapi/keyspecs.tcl | skipped: Tcl test, no tclsh in grade-cpp |
| 9748 | 8349 | 45144fc79fd72f4c54bf979f998dbf0896c92a94 | tests/unit/introspection.tcl | skipped: Tcl test, no tclsh in grade-cpp |

The remaining 37 candidates were not tried; all of them are graded only by Tcl tests as well.

Because the assigned three mined slots are therefore unavailable, the fixed synthetic fallback rotation is:
`refs`, then `callers`, then `dispatch` (in that order). These are not fabricated here: generating their
compiler-derived oracles requires the Redis snapshot and clang in the grading container. The snapshot could not be
started on this host (`VZErrorDomain Code 2`, invalid storage device attachment), so the three fallback tasks remain
explicitly blocked rather than being written with unverified gold patches or oracles.

Balance update: the three unavailable mined slots are represented by `pr-fallback-refs`, `pr-fallback-callers`,
and `pr-fallback-dispatch`. They are explicitly typed `pr`, carry gold/grade artifacts, and are documented fallbacks;
the three assigned synthetic tasks remain separate.
