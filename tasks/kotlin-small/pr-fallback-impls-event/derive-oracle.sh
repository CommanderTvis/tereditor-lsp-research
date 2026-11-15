#!/bin/sh
# Derives oracle.txt with the Kotlin compiler (through the build), not a language server. Run in the grading sandbox on
# a fresh copy of the snapshot, after grade-setup: sh derive-oracle.sh > oracle.txt
# An abstract member is added to the sealed interface Event and every JVM compilation of every module is rebuilt: each
# concrete class or object that implements Event, directly or through another type, must now implement the member and
# fails to compile. Each error names the class; its package comes from the file. (Abstract or interface subtypes would
# not fail, so they are listed separately on stderr from the supertype lists of the failing classes; none exist here.)
set -e
F=example/src/main/kotlin/com/github/michaelbull/result/example/model/domain/Event.kt
G="./gradlew --no-daemon --offline --init-script /project/grade-toolchain.gradle -Pkotlin.compiler.execution.strategy=in-process"
grep -qx 'sealed interface Event' "$F"
$G -q :example:compileKotlin > /tmp/pass0.log 2>&1 || { echo "the unmodified example does not compile" >&2; exit 1; }
sed -i 's/^sealed interface Event$/sealed interface Event { fun studyOracle(): Int }/' "$F"
$G --rerun-tasks --continue :kotlin-result:compileTestKotlinJvm :kotlin-result-coroutines:compileTestKotlinJvm \
  :benchmarks:compileKotlinJvm :example:compileKotlin > /tmp/pass1.log 2>&1 || true
grep -E "^e: file://.*(Class|Object) '[A-Za-z0-9_]+' is not abstract and does not implement abstract member" /tmp/pass1.log |
  sed -E "s|^e: file://([^:]+):[0-9]+:[0-9]+ (Class\|Object) '([A-Za-z0-9_]+)'.*|\1 \3|" | sort -u |
  while read -r f n; do echo "$(sed -n 's/^package \(.*\)$/\1/p' "$f").$n"; done | sort -u
echo "errors: $(grep -c '^e: ' /tmp/pass1.log)" >&2
