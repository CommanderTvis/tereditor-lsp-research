#!/bin/sh
# signature: the abstract declaration has the new order and no declaration keeps the old one; the hidden test (which
# calls the new order) compiles and passes with the rest of the suite.
set -e
f=runtime/src/main/java/io/quarkiverse/httpproblem/postprocessing/ProblemLogLevel.java
grep -q 'abstract void log(Logger logger, Throwable cause, String message)' "$f" || { echo "abstract declaration not reordered"; exit 1; }
if grep -rIn 'log(Logger [a-z]*, String [a-z]*, Throwable' --include=*.java --exclude-dir=target . ; then echo "old parameter order left"; exit 1; fi
sh /project/check.sh
