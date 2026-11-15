# Mined pull requests: csharp-small (MediatR)

Rule for the C# projects, fixed before any candidate was opened: grading uses the study's toolchain (`grade-csharp`:
.NET SDK 10 with runtimes 10 and 8). A pull request is built with that SDK, with the properties that only keep a newer
SDK from failing an older project (`NuGetAudit=false`, `CheckEolTargetFramework=false`, SourceLink and source control
queries off, tests rolled forward to the newest runtime with `DOTNET_ROLL_FORWARD=LatestMajor`), and its tests run for
the test project's newest .NET (Core) target framework; .NET Framework targets are not run (no Mono here). Skipped:
no test that fails at the base and passes with the change (fail to pass), a base that does not build, other tests
that fail at the base or with the change, a `global.json` pinning an SDK the toolchain cannot satisfy, a change that
adds packages or target frameworks (grading is offline), test files the pull request deletes.

Candidates come from `tasks/csharp-small/pr-candidates.jsonl` (harness/gen/mine-prs.sh, seed 20261110), taken in
order. Note: `mine-prs.sh` keeps only pull requests whose base branch has the repository's current default branch name;
MediatR renamed `master` to `main`, so all its pre-2022 pull requests target `master` and none qualified. The file
was produced by the same script with that one filter accepting `master` when the default is `main` (harness change
reported, not made). 3 pull requests qualify.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #481 | #480 | task `pr-481`: base 4f87648, tests for netcoreapp2.1 (rolled forward); fail to pass: `ExceptionTests.Should_throw_exception_for_non_generic_send_when_exception_occurs` |
| 2 | #518 | #503 | skipped: the only test change is `MediatR.Tests.csproj` (nullable annotations); no test fails at the base, so there is no fail-to-pass test |
| 3 | #655 | #484 | task `pr-655`: base e09b29c, tests for net5.0 (rolled forward); fail to pass: `RequestExceptionActionTests.Should_run_all_exception_handlers_that_match_base_type` |

Candidates ran out with 2 valid tasks: the third mined place is filled with the next refactoring type in the rotation,
`move` (`move-requestexceptionhandlerstate`), recorded in `projects/csharp-small/project.toml`.

For both tasks the generic `grade.sh` runs the fail-to-pass tests listed in `f2p.txt` (they must run and pass), then
the whole test project (pass to pass). Hidden files are the pull request's head versions of its test files; `gold.patch`
is the pull request's non-test change (base to head).
