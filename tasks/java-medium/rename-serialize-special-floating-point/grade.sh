#!/bin/sh
# No call of the old method name in the gson module's Java code (the fields of the same name stay), then the module builds
# and its tests (with the hidden one) pass.
set -e
! grep -rn --include=*.java '\bserializeSpecialFloatingPointValues()' gson
grep -rq --include=*.java 'serializeSpecialFloatingPointValuesV2()' gson/src/main
sh /project/check.sh
