#!/bin/sh
# move: the interface is declared in the new package only, nothing refers to the old name, and the build and tests pass.
set -e
new=runtime/src/main/java/io/quarkiverse/httpproblem/ProblemPostProcessor.java
[ -f "$new" ] || { echo "missing $new"; exit 1; }
grep -q '^package io\.quarkiverse\.httpproblem;' "$new" || { echo "$new is not in package io.quarkiverse.httpproblem"; exit 1; }
[ ! -e runtime/src/main/java/io/quarkiverse/httpproblem/postprocessing/ProblemPostProcessor.java ] || { echo "old file still present"; exit 1; }
left=$(grep -rIl 'httpproblem\.postprocessing\.ProblemPostProcessor' --exclude-dir=target --exclude-dir=.git . | head -n5)
[ -z "$left" ] || { echo "old qualified name left in: $left"; exit 1; }
sh /project/check.sh
