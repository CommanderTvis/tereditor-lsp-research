#!/bin/sh
# Restore NuGet packages so Roslyn can load the solution (obj/project.assets.json for every project and framework).
# Runs in the server sandbox in the snapshot itself (/workspace), with network, HOME=/cache/home. obj/ is git-ignored.
# The pin's global.json asks for SDK 10.0.x, which the managed SDK satisfies; at older commits a project that does not
# restore with the current SDK is reported, not fatal.
set -eu
dotnet=$(find /cache/managed -path '*dotnet-sdk*' -type f -name dotnet 2>/dev/null | head -n1)
[ -n "$dotnet" ] || { echo "prepare: no managed .NET SDK under /cache/managed" >&2; exit 1; }
dotnet_dir=$(dirname "$dotnet")
export DOTNET_ROOT="$dotnet_dir" PATH="$dotnet_dir:$PATH" DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
dotnet restore Jellyfin.sln -p:NuGetAudit=false || echo "prepare: restore incomplete (see above)" >&2
