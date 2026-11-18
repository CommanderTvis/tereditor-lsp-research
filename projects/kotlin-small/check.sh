#!/bin/sh
# Compiles and tests the module offline (the project's own rules are lint checks run through lint-tests; they need no
# Android SDK). TEST_FILTER, space-separated Gradle --tests patterns, restricts the run (the fail-to-pass tests of a
# mined task).
off=--offline; [ "${1:-}" = online ] && off=
f=; for t in ${TEST_FILTER:-}; do f="$f --tests $t"; done
./gradlew --no-daemon $off -q --no-configuration-cache --init-script /project/grade-toolchain.gradle \
  -Porg.gradle.java.installations.auto-download=false -Pkotlin.compiler.execution.strategy=in-process \
  :compose-lint-checks:test $f > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
