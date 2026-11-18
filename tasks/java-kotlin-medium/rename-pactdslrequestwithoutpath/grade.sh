#!/bin/sh
# rename: the class is declared under its new name only, the old name occurs nowhere as a whole word (Kotlin, Java,
# Groovy, Markdown), the file moved with it, and the build and tests pass.
set -e
new=consumer/src/main/kotlin/au/com/dius/pact/consumer/dsl/PactDslRequestNoPath.kt
[ -f "$new" ] || { echo "missing $new"; exit 1; }
[ ! -e consumer/src/main/kotlin/au/com/dius/pact/consumer/dsl/PactDslRequestWithoutPath.kt ] || { echo "old file still present"; exit 1; }
grep -q 'class PactDslRequestNoPath' "$new" || { echo "class PactDslRequestNoPath is not declared in $new"; exit 1; }
left=$(grep -rIlw 'PactDslRequestWithoutPath' --exclude-dir=.git --exclude-dir=build --exclude-dir=.gradle . | head -n5)
[ -z "$left" ] || { echo "old name left in: $left"; exit 1; }
sh /project/check.sh
