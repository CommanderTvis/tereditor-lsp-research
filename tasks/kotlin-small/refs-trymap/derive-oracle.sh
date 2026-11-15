#!/bin/sh
# Derives oracle.txt with the Kotlin compiler (through the build), not a language server. Run in the grading sandbox on
# a fresh copy of the snapshot, after grade-setup: sh derive-oracle.sh > oracle.txt
# The target is the overload declared at kotlin-result/src/commonMain/.../Map.kt:291,
#   public inline infix fun <V, E, U> Result<Iterable<V>, E>.tryMap(transform: ...)
# Pass 1: mark it @Deprecated(level = WARNING) and compile every JVM compilation of every module (main and test) from
#   scratch: each use reports a deprecation warning (except inside declarations that are themselves deprecated).
# Pass 2: rename it and compile kotlin-result's main code: each use in the module's main code (including the
#   deprecated functions of Deprecated.kt) becomes a compile error (unresolved, or no applicable candidate).
# The union of both, as path:line, is the oracle.
set -e
F=kotlin-result/src/commonMain/kotlin/com/github/michaelbull/result/Map.kt
G="./gradlew --no-daemon --offline --init-script /project/grade-toolchain.gradle -Pkotlin.compiler.execution.strategy=in-process"
sed -n '291p' "$F" | grep -q 'public inline infix fun <V, E, U> Result<Iterable<V>, E>.tryMap(' >&2
cp "$F" /tmp/Map.kt.orig
sed -i '291s/^/@Deprecated("STUDY_ORACLE", level = DeprecationLevel.WARNING) /' "$F"
$G --rerun-tasks --continue :kotlin-result:compileTestKotlinJvm :kotlin-result-coroutines:compileTestKotlinJvm \
  :benchmarks:compileKotlinJvm :example:compileKotlin > /tmp/pass1.log 2>&1 || true
grep -E '^w: file://.*STUDY_ORACLE' /tmp/pass1.log | sed -E 's|^w: file://[^ ]*/work/([^:]+):([0-9]+):.*|\1:\2|' > /tmp/o1.txt
cp /tmp/Map.kt.orig "$F"
sed -i '291s/\.tryMap(/.tryMap__oracle(/' "$F"
$G --rerun-tasks :kotlin-result:compileKotlinJvm > /tmp/pass2.log 2>&1 || true
grep -E "^e: file://" /tmp/pass2.log | sed -E 's|^e: file://[^ ]*/work/([^:]+):([0-9]+):.*|\1:\2|' > /tmp/o2.txt
cp /tmp/Map.kt.orig "$F"
echo "pass 1 (deprecation warnings): $(wc -l < /tmp/o1.txt); pass 2 (unresolved after rename): $(wc -l < /tmp/o2.txt)" >&2
grep -c '^e: ' /tmp/pass1.log >&2 || true
cat /tmp/o1.txt /tmp/o2.txt | sort -u
