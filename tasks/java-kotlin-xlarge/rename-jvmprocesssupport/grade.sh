#!/bin/sh
# Both copies of the class (main and the multi-release java9 source set) have the new file name and the old ones are gone,
# no whole-word use of the old name is left in the module, then the module's tests (the hidden one, the base and the
# Java 9 copies' own tests, which exercise the class) compile and pass.
set -e
m=platforms/core-runtime/process-services-base/src/main
for s in java java9; do
  test ! -e $m/$s/org/gradle/process/internal/jvm/JvmProcessSupport.java
  test -f $m/$s/org/gradle/process/internal/jvm/ProcessHandleSupport.java
done
! grep -rnw JvmProcessSupport platforms/core-runtime
sh /project/check.sh f2p "$TASK_DIR/f2p.txt"
sh /project/check.sh tasks :process-services-base:test :process-services-base:java9Test
