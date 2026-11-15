#!/bin/sh
# Build-and-test for Jellyfin, at the pinned commit and at the base commits of the mined pull requests.
# TEST_PROJECTS (space-separated directories under tests/) selects the test projects; default: the unit test projects
# of the solution (Jellyfin.Server.Integration.Tests starts a whole server and is left out). TEST_FILTER (a dotnet test
# filter) narrows the run. `check.sh build` only builds (grade-setup.sh, with network); grading runs offline from
# ~/.nuget.
# At the pin (global.json present, .NET 10) the whole solution is built first. Older commits (net5.0/net6.0) are built
# with the study's newer SDK: out-of-support frameworks and NuGet audit warnings must not fail the build, warnings are
# not errors (newer analyzers report what the project never saw), and tests roll forward to the newest runtime; only
# the selected test projects (and what they reference) are built.
set -e
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_ROLL_FORWARD=LatestMajor
props="-p:NuGetAudit=false -p:CheckEolTargetFramework=false -p:EnableSourceLink=false -p:EnableSourceControlManagerQueries=false"
if [ -f global.json ]; then
  [ -n "${TEST_PROJECTS:-}" ] || dotnet build Jellyfin.sln -nologo -v q $props
else
  props="$props -p:TreatWarningsAsErrors=false -p:RunAnalyzers=false"
fi
projects=${TEST_PROJECTS:-$(ls -d tests/*.Tests | grep -v 'Integration' | sed 's|^tests/||' | tr '\n' ' ')}
for p in $projects; do dotnet build "tests/$p" -nologo -v q $props || [ "${1:-}" = build ]; done
[ "${1:-}" = build ] && exit 0
for p in $projects; do
  dotnet test "tests/$p" --no-build -nologo -v q $props ${TEST_FILTER:+--filter "$TEST_FILTER"}
done
