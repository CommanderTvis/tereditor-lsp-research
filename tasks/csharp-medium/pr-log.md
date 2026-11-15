# Mined pull requests: csharp-medium (AutoMapper)

Rule (the same for every C# project, fixed before any candidate was opened; see tasks/csharp-small/pr-log.md): built
and tested with the study's toolchain (.NET SDK 10, runtimes 10 and 8), with only the properties that keep a newer
SDK from failing an older project (NuGet audit, end-of-life frameworks, SourceLink/source control queries; at older
commits warnings are not errors), tests for the test project's newest .NET (Core) target framework, rolled forward.
Skipped: no fail-to-pass test, a base that does not build, other failing tests, an SDK pin the toolchain cannot
satisfy, a change that adds packages or target frameworks (grading is offline), test files the pull request deletes.

`project.toml` named the repository by its old name (AutoMapper/AutoMapper); GitHub's search does not follow the
redirect, so mine-prs.sh found nothing. The repository is now named by its canonical name
(LuckyPennySoftware/AutoMapper), and mine-prs.sh ran with the default-branch filter also accepting `master` (as for
csharp-small: the harness change is reported, not made). 23 pull requests qualify; all 23 are skipped.

The decisive reason applies to all of them: every candidate's base commit predates upstream commit 17511cf
("allow building on Linux", 2022-03-11), and at each of them `src/UnitTests/Internationalization.cs` is
Windows-1252 (ISO-8859) text, which the compiler reads as UTF-8 off Windows: the unit test project does not compile
(CS1056 "Unexpected character", CS1519). Checked for every candidate with
`git show <base>:src/UnitTests/Internationalization.cs | file -` and `git merge-base --is-ancestor <base> 17511cf`,
and confirmed by building the first ones in order:

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #2038 | #2037 | skipped: the tests are only in `UnitTests.Net4.csproj` (non-SDK .NET Framework project); base predates the Linux fix |
| 2 | #2280 | #2278 | skipped: the change adds a package (`System.Reflection.Emit` to AutoMapper.csproj); base predates the Linux fix |
| 3 | #2268 | #2267 | skipped: base does not build (Internationalization.cs encoding, built: CS1056) |
| 4 | #2177 | #2166 | skipped: tests only in `UnitTests.Net4.csproj`; base predates the Linux fix |
| 5 | #1848 | #1847 | skipped: `global.json` pins SDK 1.0.0-preview2 (project.json); base predates the Linux fix |
| 6 | #2741 | #2740 | skipped: base does not build (Internationalization.cs encoding, built: CS1056) |
| 7-23 | #2873, #3041, #2025, #2403, #2297, #3366, #1805, #2202, #2294, #3411, #1677, #3487, #2230, #3030, #2682, #2677, #2147 | | skipped: base predates the Linux fix, Internationalization.cs is ISO-8859 text (not built) |

Candidates ran out with 0 valid tasks: the three mined places are filled with synthetic tasks of the next types in the
rotation (rename, rename-file, callers), recorded in `projects/csharp-medium/project.toml`.
