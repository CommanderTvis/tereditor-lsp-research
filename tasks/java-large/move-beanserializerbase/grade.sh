#!/bin/sh
# move: BeanSerializerBase is declared in the ser package only, nothing refers to the old name, and the build and tests pass.
set -e
new=src/main/java/tools/jackson/databind/ser/BeanSerializerBase.java
[ -f "$new" ] || { echo "missing $new"; exit 1; }
grep -q '^package tools\.jackson\.databind\.ser;' "$new" || { echo "$new is not in package tools.jackson.databind.ser"; exit 1; }
[ ! -e src/main/java/tools/jackson/databind/ser/bean/BeanSerializerBase.java ] || { echo "old file still present"; exit 1; }
left=$(grep -rIl 'databind\.ser\.bean\.BeanSerializerBase' --exclude-dir=target --exclude-dir=.git . | head -n5)
[ -z "$left" ] || { echo "old qualified name left in: $left"; exit 1; }
sh /project/check.sh
