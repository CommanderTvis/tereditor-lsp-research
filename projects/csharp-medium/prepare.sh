#!/bin/sh
# Restore NuGet packages so Roslyn can load the solution (obj/project.assets.json for every project and framework).
# Runs in the server sandbox in the snapshot itself (/workspace), with network, HOME=/cache/home. obj/ is git-ignored.
set -eu
# the managed cache may hold SDKs of several architectures (shared state volume): take one that runs here
dotnet=""; for d in $(find /cache/managed -path '*dotnet-sdk*' -type f -name dotnet 2>/dev/null); do "$d" --version >/dev/null 2>&1 && { dotnet=$d; break; }; done
[ -n "$dotnet" ] || { echo "prepare: no managed .NET SDK under /cache/managed" >&2; exit 1; }
dotnet_dir=$(dirname "$dotnet")
export DOTNET_ROOT="$dotnet_dir" PATH="$dotnet_dir:$PATH" DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
sln=$(ls *.slnx *.sln 2>/dev/null | head -n1)
dotnet restore "$sln" -p:NuGetAudit=false
