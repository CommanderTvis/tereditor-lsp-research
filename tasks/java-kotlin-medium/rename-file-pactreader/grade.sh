#!/bin/sh
# rename-file: the file lives at its new path only, nothing names the old facade class, and the build and tests pass.
set -e
d=core/model/src/main/kotlin/au/com/dius/pact/core/model
[ -f "$d/PactReaderUtils.kt" ] || { echo "missing $d/PactReaderUtils.kt"; exit 1; }
[ -z "$(find . -name PactReader.kt -not -path './.git/*' -not -path '*/build/*' | head -n1)" ] || { echo "PactReader.kt still present"; exit 1; }
left=$(grep -rIlw 'PactReaderKt' --exclude-dir=.git --exclude-dir=build --exclude-dir=.gradle . | head -n5)
[ -z "$left" ] || { echo "old facade class name left in: $left"; exit 1; }
sh /project/check.sh
