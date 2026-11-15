#!/bin/sh
# Derives oracle.txt from compiled classes, not a language server. Run in the grading sandbox on a fresh copy of the
# snapshot, after grade-setup: sh derive-oracle.sh > oracle.txt
# Every module's main and test code is compiled for the JVM; then the JVM itself (Class.isAssignableFrom, without
# initialising any class) decides which named classes in those class directories are subtypes of Taggable.
set -e
d=$(dirname "$0")
G="./gradlew --no-daemon --offline -q -Pkotlin.compiler.execution.strategy=in-process"
$G :kotlinpoet:jvmTestClasses :interop:kotlin-metadata:testClasses :interop:ksp:testClasses :interop:ksp:test-processor:testClasses >&2
cp=$($G --init-script "$d/classpath.gradle" studyClasspath | sed -n 's/^STUDY_CP=//p' | tr '\n' ':')
dirs=$(find . -path '*/build/classes/*' -type d -name com -prune | sed 's|/com$||' | sort -u)
echo "class directories: $(echo $dirs)" >&2
java "$d/StudyImpls.java" com.squareup.kotlinpoet.Taggable "$cp" $dirs
