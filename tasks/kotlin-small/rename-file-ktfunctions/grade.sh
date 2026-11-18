#!/bin/sh
# rename-file: the file lives at its new path only, nothing names the old path, and the module builds and passes its tests.
set -e
d=compose-lint-checks/src/main/java/slack/lint/compose/util
[ -f "$d/KtFunctionsExt.kt" ] || { echo "missing $d/KtFunctionsExt.kt"; exit 1; }
[ -z "$(find . -name KtFunctions.kt -not -path './.git/*' -not -path '*/build/*' | head -n1)" ] || { echo "KtFunctions.kt still present"; exit 1; }
left=$(grep -rIlF 'KtFunctions.kt' --exclude-dir=.git --exclude-dir=build --exclude-dir=.gradle . | head -n5)
[ -z "$left" ] || { echo "old file name left in: $left"; exit 1; }
sh /project/check.sh
