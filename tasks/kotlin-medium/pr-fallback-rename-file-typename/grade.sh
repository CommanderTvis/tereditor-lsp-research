#!/bin/sh
# The file is renamed (old path gone, new path present, still declaring TypeName), then everything builds and the
# tests pass, the hidden one checking that the JVM facade class follows the new file name.
d=kotlinpoet/src/jvmMain/kotlin/com/squareup/kotlinpoet
[ ! -e "$d/TypeName.kt" ] || { echo "grade: TypeName.kt still exists"; exit 1; }
grep -q '^public sealed class TypeName' "$d/TypeNameFactories.kt" || { echo "grade: TypeNameFactories.kt missing or changed"; exit 1; }
sh /project/check.sh
