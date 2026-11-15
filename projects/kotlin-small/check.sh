#!/bin/sh
# Builds every module's JVM, JS and Wasm code (main and test) and runs the JVM tests, offline. Native targets are not
# compiled (no Kotlin/Native toolchain in the grading sandbox); the tasks' grade.sh cover their few sources by text.
off=--offline; [ "${1:-}" = online ] && off=
./gradlew --no-daemon $off -q --init-script /project/grade-toolchain.gradle \
  -Porg.gradle.java.installations.auto-download=false -Pkotlin.compiler.execution.strategy=in-process --continue \
  :kotlin-result:jvmTest :kotlin-result-coroutines:jvmTest \
  :kotlin-result:compileTestKotlinJs :kotlin-result-coroutines:compileTestKotlinJs \
  :kotlin-result:compileTestKotlinWasmJs :kotlin-result-coroutines:compileTestKotlinWasmJs \
  :benchmarks:compileKotlinJvm :example:compileTestKotlin > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
