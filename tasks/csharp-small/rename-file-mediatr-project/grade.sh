#!/bin/sh
# rename-file: the project lives at its new path only (bin/ and obj/ left by the build cache do not count), the
# solution builds against it, and the tests pass.
set -e
[ -f src/MediatR.Core/MediatR.Core.csproj ] || { echo "missing src/MediatR.Core/MediatR.Core.csproj"; exit 1; }
left=$(find src/MediatR -type f -not -path '*/obj/*' -not -path '*/bin/*' 2>/dev/null | head -n5)
[ -z "$left" ] || { echo "files left under src/MediatR: $left"; exit 1; }
grep -q 'src[\\/]MediatR\.Core[\\/]MediatR\.Core\.csproj' *.sln || { echo "the solution does not list the renamed project"; exit 1; }
sh /project/check.sh
ls test/MediatR.Tests/bin/Debug/*/MediatR.Core.dll >/dev/null 2>&1 || { echo "the tests do not load MediatR.Core.dll"; exit 1; }
