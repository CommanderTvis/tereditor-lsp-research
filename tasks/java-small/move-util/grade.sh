#!/bin/sh
# Util is declared in the new package only, nothing refers to the old one, then the build and the tests (with the
# hidden one) pass.
set -e
test ! -e src/main/java/com/squareup/javapoet/Util.java
test -f src/main/java/com/squareup/javapoet/internal/Util.java
! grep -rn --include=*.java 'com\.squareup\.javapoet\.Util\b' src
sh /project/check.sh
