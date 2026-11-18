#!/bin/sh
# Build-and-test for Spectre.Console, at the pinned commit and at the base commits of the mined pull requests.
# Tests: the Spectre.Console.Tests project (at older commits under test/, now under src/), for net10.0 when it targets it,
# else its newest target framework. Bases that pin SDK 11 in global.json (merged from 2026-11-17 on) use the study's
# SDK 11 (study-dotnet11); everything else uses SDK 10. TEST_FILTER (a dotnet test filter) narrows the run.
# `check.sh build` only builds (grade-setup.sh, with network); grading runs offline from ~/.nuget.
set -e
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_ROLL_FORWARD=LatestMajor
if grep -q '"version": *"11' global.json 2>/dev/null; then
  PATH="$(study-dotnet11)/bin:$PATH"; export PATH
  sdkv=$(dotnet --list-sdks | sed -n 's/^\(11[^ ]*\) .*/\1/p' | tail -n1)
  sed -i -E "s/(\"version\": \")[0-9][^\"]*\"/\1$sdkv\"/" global.json
fi
props="-p:NuGetAudit=false -p:CheckEolTargetFramework=false -p:EnableSourceLink=false -p:EnableSourceControlManagerQueries=false -p:TreatWarningsAsErrors=false"
tp=$(find . -name Spectre.Console.Tests.csproj -not -path '*/obj/*' | head -n1)
all=$(sed -n 's:.*<TargetFrameworks\{0,1\}>\([^<]*\)</TargetFrameworks\{0,1\}>.*:\1:p' "$tp" | tr ';' '\n' | grep -v '^$')
if echo "$all" | grep -qx net10.0; then tfm=net10.0
else tfm=$(echo "$all" | grep '\.' | awk '{v=$0; sub(/^netcoreapp|^net/, "", v); print v "\t" $0}' | sort -V | tail -n1 | cut -f2); fi
dotnet build "$tp" -f "$tfm" -nologo -v q $props
[ "${1:-}" = build ] && exit 0
dotnet test "$tp" -f "$tfm" --no-build -nologo -v "${TEST_VERBOSITY:-q}" $props ${TEST_FILTER:+--filter "$TEST_FILTER"}
