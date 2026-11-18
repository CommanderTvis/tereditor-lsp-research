#!/bin/sh
# Build-and-test for EF Core, at the pinned commit and at the base commits of the mined pull requests.
# TEST_PROJECTS (space-separated directories under test/) selects the test projects; default: EFCore.Tests. TEST_FILTER
# (space-separated xUnit v3 method-name patterns, each passed as --filter-method) narrows the run. TEST_VERBOSITY sets the
# verbosity of the test run; TEST_CLASSES (space-separated patterns, --filter-class) narrows it to test classes. `check.sh build` only builds (grade-setup.sh, with network); grading runs offline from ~/.nuget.
# Only library test projects that build in minutes are graded: SQL Server, Cosmos and Azure projects are not.
set -e
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_ROLL_FORWARD=LatestMajor DOTNET_ROLL_FORWARD_TO_PRERELEASE=1
# The repository's main branch targets a .NET 12 alpha (and the release branch the 11 release): the study's grading
# environment carries the .NET 11 SDK and runtime only, so every commit is built for net11.0 against the installed runtime.
PATH="$(study-dotnet11)/bin:$PATH"   # SDK 11 is opt-in: the grading environment defaults to SDK 10
rt=$(dotnet --list-runtimes | sed -n 's/^Microsoft.NETCore.App \(11[^ ]*\) .*/\1/p' | tail -n1)
props="-p:NuGetAudit=false -p:CheckEolTargetFramework=false -p:EnableSourceLink=false -p:EnableSourceControlManagerQueries=false -p:TreatWarningsAsErrors=false -p:NetCurrent=net11.0 -p:DefaultNetCoreTargetFramework=net11.0"
# A commit may pin a newer SDK build than the installed one (global.json): ask for the installed .NET 11 SDK instead (the work tree only).
sdkv=$(dotnet --list-sdks | sed -n 's/^\(11[^ ]*\) .*/\1/p' | tail -n1)
[ -f global.json ] && sed -i -E "s/(\"(version|dotnet)\": \")[0-9][^\"]*\"/\1$sdkv\"/" global.json
projects=${TEST_PROJECTS:-EFCore.Tests}
for p in $projects; do dotnet build "test/$p/$p.csproj" -nologo -v q $props; done
[ "${1:-}" = build ] && exit 0
# The built test hosts ask for the runtime version their commit was built against (11.0.0 or a 12 alpha): run them on the
# installed .NET 11 runtime.
find artifacts/bin -name '*.runtimeconfig.json' -exec sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$rt\"/" {} +
for p in $projects; do
  set -- --project "test/$p/$p.csproj" --no-build -nologo -v "${TEST_VERBOSITY:-q}" $props
  for f in ${TEST_FILTER:-}; do set -- "$@" --filter-method "$f"; done
  for f in ${TEST_CLASSES:-}; do set -- "$@" --filter-class "$f"; done
  dotnet test "$@"
done
