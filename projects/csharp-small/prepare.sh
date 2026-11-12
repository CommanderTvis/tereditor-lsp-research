#!/bin/sh
# Restore NuGet packages so Roslyn can load the solution (obj/project.assets.json for every project and framework).
# Runs as uid 1000 in the run image, with network, HOME=/cache/home: packages land in /cache/home/.nuget/packages.
# The run image copies /study/snapshot to /workspace; the restore is done at /workspace (the path the language server
# sees, since obj/ files embed absolute paths) and obj/ is copied back.
set -eu
dotnet_dir=$(dirname "$(ls -d /cache/managed/runtimes/dotnet-sdk/*/dotnet | head -n1)")
export DOTNET_ROOT="$dotnet_dir" PATH="$dotnet_dir:$PATH" DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 \
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 NuGetAudit=false
printf 'bin/\nobj/\n' >> .git/info/exclude
snap=$(pwd)
rm -rf /workspace/* /workspace/.[!.]* 2>/dev/null || true
cp -a "$snap/." /workspace/
cd /workspace
dotnet restore MediatR.sln
find . -type d -name obj -prune | while read -r d; do mkdir -p "$snap/$d" && cp -a "$d/." "$snap/$d/"; done
cd "$snap"
rm -rf /workspace/* /workspace/.[!.]* 2>/dev/null || true
