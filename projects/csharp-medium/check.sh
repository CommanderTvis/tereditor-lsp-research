#!/bin/sh
# Build-and-test for AutoMapper, at the pinned commit and at the base commits of the mined pull requests.
# The study's .NET SDK (10) can be newer than the project's: out-of-support target frameworks and NuGet audit warnings
# must not fail the build (the project treats warnings as errors), the old SourceLink packages of earlier commits crash
# on it (source control queries off), at older commits warnings are not errors (a newer SDK reports warnings the
# project never saw, such as NU1504), and tests run on the newest runtime present (roll forward).
# At the pin: the whole solution (AutoMapper.slnx) is built and the unit and dependency-injection tests run; the
# integration tests need a SQL Server container and are built but not run. At older commits: the unit test project
# only, for its newest .NET (Core) target framework (.NET Framework targets cannot run here).
# `check.sh build` only builds (grade-setup.sh, with network); grading runs offline from ~/.nuget. TEST_FILTER (a
# dotnet test filter) narrows the test run.
set -e
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_ROLL_FORWARD=LatestMajor
props="-p:NuGetAudit=false -p:CheckEolTargetFramework=false -p:EnableSourceLink=false -p:EnableSourceControlManagerQueries=false"
test_run() { dotnet test "$@" --no-build -nologo -v q $props ${TEST_FILTER:+--filter "$TEST_FILTER"}; }
if [ -f AutoMapper.slnx ]; then
  dotnet build AutoMapper.slnx -nologo -v q $props
  [ "${1:-}" = build ] && exit 0
  test_run src/UnitTests/AutoMapper.UnitTests.csproj -f net10.0
  [ -n "${TEST_FILTER:-}" ] || test_run src/AutoMapper.DI.Tests/AutoMapper.DI.Tests.csproj
else
  tp=$(ls src/UnitTests/*.csproj | grep -vi 'net4' | head -n1)
  all=$(sed -n 's:.*<TargetFrameworks\{0,1\}>\([^<]*\)</TargetFrameworks\{0,1\}>.*:\1:p' "$tp" | tr ';' '\n' | grep -v '^$')
  tfm=$(echo "$all" | grep '\.' | awk '{v=$0; sub(/^netcoreapp|^net/, "", v); print v "\t" $0}' | sort -V | tail -n1 | cut -f2)
  props="$props -p:TreatWarningsAsErrors=false"
  dotnet build "$tp" -f "$tfm" -nologo -v q $props
  [ "${1:-}" = build ] && exit 0
  test_run "$tp" -f "$tfm"
fi
