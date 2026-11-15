#!/bin/sh
# Builds every module (kotlinpoet's JVM, JS and Wasm code, main and test; the JVM interop modules) and runs the JVM
# tests, offline. Kotlin warnings are errors in this build (allWarningsAsErrors), as upstream.
off=--offline; [ "${1:-}" = online ] && off=
./gradlew --no-daemon $off -q -Pkotlin.compiler.execution.strategy=in-process --continue \
  :kotlinpoet:jvmTest :kotlinpoet:compileTestKotlinJs :kotlinpoet:compileTestKotlinWasmJs \
  :interop:kotlin-metadata:test :interop:ksp:test :interop:ksp:test-processor:test > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
