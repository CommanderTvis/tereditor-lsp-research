# Mined pull requests: csharp-xlarge (dotnet/efcore)

Modern pull requests (opened on or after 2026-07-01, merged; docs/MEMORIZATION.md). `harness/gen/mine-prs.sh` found 111
that qualify (closing issue, tests plus source), 60 listed in seeded order (seed 20261110). Graded test projects:
EFCore.Tests, EFCore.InMemory.FunctionalTests, EFCore.Sqlite.FunctionalTests, Microsoft.Data.Sqlite.Tests,
EFCore.Relational.Tests, dotnet-ef.Tests (no SQL Server, Cosmos or Azure). Hidden tests are the base file plus the pull
request's own test diff. Fail-to-pass tests (`f2p.txt`) are the test methods the pull request adds.

| Order | PR | Outcome |
| --- | --- | --- |
| 1 | #39354 | task `pr-39354`, VALID; memprobe in `pr-39354/memprobe.txt` |
| 2 | #39500 | skipped: base targets the .NET 12 alpha; the Sqlite functional test host fails to load System.Runtime 12 on the .NET 11 runtime |
| 3, 4 | #39162, #39161 | skipped: tests only in EFCore.SqlServer.FunctionalTests (not graded) |
| 5 | #39514 | skipped: same .NET 12 alpha runtime failure as #39500 |
| 6 | #38719 | skipped: base builds, but the dotnet-ef test project restores packages from pkgs.dev.azure.com during grading (offline) |
| 7 | #38554 | skipped: base does not build with the installed SDK (compiler error CS9385/CS9386 on a C# union type in ModelValidatorTest.cs) |
| 8+ | | not tried: most later bases target the .NET 12 alpha; stopped for machine load (about 10 to 50 minutes per candidate cycle) |

Two slots are empty (`pr_shortfall = 2` in projects/csharp-xlarge/project.toml).
