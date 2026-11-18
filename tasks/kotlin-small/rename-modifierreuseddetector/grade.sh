#!/bin/sh
# rename: the class is declared under its new name only, the old name occurs nowhere as a whole word (sources, tests,
# KDoc, docs, configuration), the file moved with it, and the module builds and passes its tests.
set -e
new=compose-lint-checks/src/main/java/slack/lint/compose/ModifierReusedCheck.kt
[ -f "$new" ] || { echo "missing $new"; exit 1; }
[ ! -e compose-lint-checks/src/main/java/slack/lint/compose/ModifierReusedDetector.kt ] || { echo "old file still present"; exit 1; }
grep -q '^class ModifierReusedCheck' "$new" || { echo "class ModifierReusedCheck is not declared in $new"; exit 1; }
left=$(grep -rIlw 'ModifierReusedDetector' --exclude-dir=.git --exclude-dir=build --exclude-dir=.gradle . | head -n5)
[ -z "$left" ] || { echo "old name left in: $left"; exit 1; }
sh /project/check.sh
