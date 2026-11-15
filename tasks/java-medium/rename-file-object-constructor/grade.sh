#!/bin/sh
# The file has its new name and the old one is gone, no trace of the old type name in the gson module's Java code, then
# the module builds and its tests (with the hidden one) pass.
set -e
test ! -e gson/src/main/java/com/google/gson/internal/ObjectConstructor.java
test -f gson/src/main/java/com/google/gson/internal/ObjectFactory.java
! grep -rn --include=*.java '\bObjectConstructor\b' gson
sh /project/check.sh
