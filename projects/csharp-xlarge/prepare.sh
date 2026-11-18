#!/bin/sh
# Restore NuGet packages so Roslyn can load the test project and the library. Runs in the server sandbox in the snapshot
# (/workspace), with network, HOME=/cache/home. obj/ is git-ignored.
set -eu
# the managed cache may hold SDKs of several architectures (shared state volume): take one that runs here
dotnet=""; for d in $(find /cache/managed -path '*dotnet-sdk*' -type f -name dotnet 2>/dev/null); do (cd / && "$d" --version) >/dev/null 2>&1 && { dotnet=$d; break; }; done
[ -n "$dotnet" ] || { echo "prepare: no managed .NET SDK under /cache/managed" >&2; exit 1; }
dotnet_dir=$(dirname "$dotnet")
export DOTNET_ROOT="$dotnet_dir" PATH="$dotnet_dir:$PATH" DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
dotnet restore Tests/Linq/Tests.csproj -p:NuGetAudit=false || echo "prepare: restore incomplete (see above)" >&2
rm -f "Data/Setup Scripts/UserDataProviders.json"
