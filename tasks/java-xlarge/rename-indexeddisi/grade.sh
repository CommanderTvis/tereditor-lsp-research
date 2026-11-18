#!/bin/sh
# The declaration's file has its new name and the old one is gone, no reference to the old fully qualified name is left, then
# every module of the repository compiles (main and tests) and the hidden test and the type's own tests pass.
set -e
test ! -e lucene/core/src/java/org/apache/lucene/codecs/lucene90/IndexedDISI.java
test -f lucene/core/src/java/org/apache/lucene/codecs/lucene90/JumpTableDISI.java
! grep -rn --include=*.java 'org\.apache\.lucene\.codecs\.lucene90\.IndexedDISI' lucene
! grep -rnw --include=*.java IndexedDISI lucene/core
sh /project/check.sh compile
sh /project/check.sh f2p "$TASK_DIR/f2p.txt"
