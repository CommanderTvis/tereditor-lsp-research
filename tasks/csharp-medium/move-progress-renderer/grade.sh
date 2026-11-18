#!/bin/sh
# Build and tests pass; ProgressRenderer is declared only in the new namespace and file.
set -eu
sh /project/check.sh
[ ! -e src/Spectre.Console/Live/Progress/ProgressRenderer.cs ] || { echo "old file still present"; exit 1; }
f=src/Spectre.Console/Live/Progress/Rendering/ProgressRenderer.cs
[ -e "$f" ] || { echo "new file missing"; exit 1; }
grep -q '^namespace Spectre.Console.ProgressRendering;' "$f" || { echo "wrong namespace in the new file"; exit 1; }
n=$(grep -rIlE --include='*.cs' 'class ProgressRenderer\b' src | wc -l | tr -d ' ')
[ "$n" = 1 ] || { echo "ProgressRenderer must be declared exactly once, found $n"; exit 1; }
