#!/bin/sh
# Builds every module (kotlinpoet's JVM, JS and Wasm code, main and test; the JVM interop modules) and runs the JVM
# tests, offline. Kotlin warnings are errors in this build (allWarningsAsErrors), as upstream. TEST_FILTER, lines
# "<gradle-task> <test-class>" (the fail-to-pass test classes of a mined task), restricts the run to them.
off=--offline; [ "${1:-}" = online ] && off=
if [ -n "${TEST_FILTER:-}" ]; then
  tasks=$(printf '%s\n' "$TEST_FILTER" | sort | awk 'NF==2 {if ($1!=p) {printf " %s", $1; p=$1}; printf " --tests %s", $2}')
else
  tasks=":kotlinpoet:jvmTest :kotlinpoet:compileTestKotlinJs :kotlinpoet:compileTestKotlinWasmJs :interop:kotlin-metadata:test :interop:ksp:test :interop:ksp:test-processor:test"
fi
./gradlew --no-daemon $off -q -Pkotlin.compiler.execution.strategy=in-process --continue $tasks > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
