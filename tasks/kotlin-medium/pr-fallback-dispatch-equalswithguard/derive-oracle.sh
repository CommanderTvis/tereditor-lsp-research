#!/bin/sh
# Derives oracle.txt by running the code, not with a language server. Run in the grading sandbox on a fresh copy of the
# snapshot, after grade-setup: sh derive-oracle.sh > oracle.txt
# Every definition of equalsWithGuard (found by text; the script checks there are exactly 6) gets a first statement
# that appends its own path:line to a file; a JVM test evaluates the expression of the prompt; the distinct lines
# written are the definitions that ran.
set -e
d=kotlinpoet/src/jvmMain/kotlin/com/squareup/kotlinpoet
n=0
for f in $(grep -lE 'fun equalsWithGuard\(' -r kotlinpoet interop --include=*.kt | sort); do
  l=$(grep -nE 'fun equalsWithGuard\(other: TypeName, seen: RecursiveComparison\): Boolean \{$' "$f" | cut -d: -f1)
  [ "$(echo "$l" | wc -w)" = 1 ] || { echo "unexpected declarations in $f" >&2; exit 1; }
  sed -i "${l}s|\$| java.io.File(\"/tmp/study-dispatch.txt\").appendText(\"$f:$l\\\\n\");|" "$f"
  n=$((n + 1))
done
[ "$n" = 6 ] || { echo "expected 6 definitions, found $n" >&2; exit 1; }
cat > kotlinpoet/src/jvmTest/kotlin/com/squareup/kotlinpoet/StudyDispatchProbe.kt <<'K'
package com.squareup.kotlinpoet

import com.squareup.kotlinpoet.ParameterizedTypeName.Companion.parameterizedBy
import kotlin.test.Test

class StudyDispatchProbe {
  @Test fun run() {
    val a = LambdaTypeName.get(returnType = LIST.parameterizedBy(STRING))
    val b = LambdaTypeName.get(returnType = LIST.parameterizedBy(INT))
    java.io.File("/tmp/study-dispatch.txt").writeText("")
    java.io.File("/tmp/study-dispatch-result.txt").writeText((a == b).toString())
  }
}
K
./gradlew --no-daemon --offline -q -Pkotlin.compiler.execution.strategy=in-process :kotlinpoet:jvmTest \
  --tests com.squareup.kotlinpoet.StudyDispatchProbe >&2
echo "a == b: $(cat /tmp/study-dispatch-result.txt); calls: $(grep -c . /tmp/study-dispatch.txt)" >&2
cat /tmp/study-dispatch.txt >&2
grep . /tmp/study-dispatch.txt | sort -u
