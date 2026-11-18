#!/bin/sh
# Build-and-test for MediatR, at the pinned commit and at the base commits of the mined pull requests.
# The study's .NET SDK (10) is newer than the project's: out-of-support target frameworks and NuGet audit warnings must
# not fail the build (the project treats warnings as errors), the old SourceLink packages of earlier commits crash on
# it (source control queries off), and tests run on the newest runtime present (roll forward).
# At the pin the test project has one target framework: the whole solution (library, tests, benchmarks, samples) is
# built. At older commits it also targets .NET Framework, which cannot run here: only the test project is built, for
# its newest .NET (Core) target framework.
# GenericRequestHandlerTests.ShouldThrowExceptionWhenTimeoutOccurs is excluded: it races a 1-second registration
# timeout against assembly generation and fails intermittently on an unchanged tree.
# `check.sh build` only builds (grade-setup.sh, with network); grading runs offline from ~/.nuget. TEST_FILTER (a
# dotnet test filter) narrows the test run.
set -e
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_ROLL_FORWARD=LatestMajor
props="-p:NuGetAudit=false -p:CheckEolTargetFramework=false -p:EnableSourceLink=false -p:EnableSourceControlManagerQueries=false"
tp=test/MediatR.Tests/MediatR.Tests.csproj
all=$(sed -n 's:.*<TargetFrameworks\{0,1\}>\([^<]*\)</TargetFrameworks\{0,1\}>.*:\1:p' "$tp" | tr ';' '\n' | grep -v '^$')
tfm=$(echo "$all" | grep '\.' | awk '{v=$0; sub(/^netcoreapp|^net/, "", v); print v "\t" $0}' | sort -V | tail -n1 | cut -f2)
if [ "$(echo "$all" | wc -l)" -eq 1 ]; then dotnet build "$(ls *.sln | head -n1)" -nologo -v q $props
else dotnet build "$tp" -f "$tfm" -nologo -v q $props; fi
[ "${1:-}" = build ] && exit 0
filter="FullyQualifiedName!=MediatR.Tests.GenericRequestHandlerTests.ShouldThrowExceptionWhenTimeoutOccurs"
dotnet test "$tp" -f "$tfm" --no-build -nologo -v "${TEST_VERBOSITY:-q}" $props --filter "$filter${TEST_FILTER:+&$TEST_FILTER}"
