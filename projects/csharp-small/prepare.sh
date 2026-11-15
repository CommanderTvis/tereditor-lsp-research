#!/bin/sh
# Restore NuGet packages so Roslyn can load the solution (obj/project.assets.json for every project and framework).
# Runs in the server sandbox in the snapshot itself (/workspace, the path the language server sees; obj/ files embed
# absolute paths), with network, HOME=/cache/home: packages land in /cache/home/.nuget/packages. obj/ is git-ignored.
# At older commits a sample project may not restore with the current SDK; the rest is still restored and the failure
# is reported, not fatal (the probe checks what the language server understands).
set -eu
dotnet=$(find /cache/managed -path '*dotnet-sdk*' -type f -name dotnet 2>/dev/null | head -n1)
[ -n "$dotnet" ] || { echo "prepare: no managed .NET SDK under /cache/managed" >&2; exit 1; }
dotnet_dir=$(dirname "$dotnet")
export DOTNET_ROOT="$dotnet_dir" PATH="$dotnet_dir:$PATH" DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 \
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
dotnet restore "$(ls *.sln | head -n1)" -p:NuGetAudit=false || echo "prepare: restore incomplete (see above)" >&2
