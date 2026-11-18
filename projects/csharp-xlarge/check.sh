#!/bin/sh
# Build-and-test for linq2db, at the pinned commit and at the base commits of the mined pull requests.
# Only the Tests/Linq test project (linq2db.Tests) is built, for net10.0, and only the SQLite provider (--provider SQLite.MS)
# is run: it needs no database server. TEST_FILTER (a VSTest-style filter expression) narrows the run;
# TEST_VERBOSITY is accepted for symmetry with the other projects. `check.sh build` only builds (grade-setup.sh, with
# network); grading runs offline from ~/.nuget. X86STUBS=True builds the test assembly with stubs for the DB2 and SAP HANA
# native client libraries (their vendor assemblies are x64-only, and without the stubs NUnit finds 0 tests on arm64).
set -e
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_ROLL_FORWARD=LatestMajor
props="-p:NuGetAudit=false -p:CheckEolTargetFramework=false -p:EnableSourceLink=false -p:EnableSourceControlManagerQueries=false -p:TreatWarningsAsErrors=false -p:ContinuousIntegrationBuild=false -p:X86STUBS=True"
dotnet build Tests/Linq/Tests.csproj -f net10.0 -nologo -v q $props
# The build writes an ignored file whose name has a space; the harness's overlay copy cannot handle quoted paths.
rm -f "Data/Setup Scripts/UserDataProviders.json"
[ "${1:-}" = build ] && exit 0
dll=$(find . -name linq2db.Tests.dll -path '*net10.0*' -not -path '*/obj/*' | head -n1)
[ -n "$dll" ] || { echo "linq2db.Tests.dll not found"; exit 1; }
cd "$(dirname "$dll")"
dotnet linq2db.Tests.dll --provider SQLite.MS ${TEST_FILTER:+--filter "$TEST_FILTER"}
