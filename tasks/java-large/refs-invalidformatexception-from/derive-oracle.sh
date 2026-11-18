#!/bin/sh
# Run in the grading sandbox (JDK 21, Maven, offline) with the pinned jackson-databind snapshot at $1 (copied, not
# modified): prints one `path:line` per use of InvalidFormatException.from, by compiler mutation. The static method
# is renamed at its declaration and every source file is compiled with javac; the "cannot find symbol" errors for
# `from` are the uses (errors elsewhere also exist before the mutation: none, checked first).
set -e
src=${1:-/study/snapshot}
rm -rf /tmp/o && cp -a "$src" /tmp/o && cd /tmp/o
mvn -B -q -o generate-sources dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt -Dmdep.includeScope=test >/dev/null
find src/main/java src/test/java -name '*.java' ! -name module-info.java | sort > /tmp/srcs.txt
[ -d target/generated-sources ] && find target/generated-sources -name '*.java' >> /tmp/srcs.txt
compile() { rm -rf /tmp/classes && mkdir -p /tmp/classes
  javac -proc:none -Xmaxerrs 100000 -nowarn -d /tmp/classes -cp "$(cat /tmp/cp.txt)" @/tmp/srcs.txt 2>&1 | grep -E '^[^ ]+\.java:[0-9]+: error' || true; }
compile > /tmp/before.txt
echo "errors before the mutation: $(wc -l < /tmp/before.txt)" >&2
f=src/main/java/tools/jackson/databind/exc/InvalidFormatException.java
grep -n 'static InvalidFormatException from(' "$f" >&2
sed -i 's/static InvalidFormatException from(/static InvalidFormatException from__mutated(/' "$f"
compile > /tmp/after.txt
echo "errors after the mutation: $(wc -l < /tmp/after.txt)" >&2
comm -13 /tmp/before.txt /tmp/after.txt | grep -v 'from__mutated' | sed 's/^/OTHER: /' >&2 || true
comm -13 /tmp/before.txt /tmp/after.txt | sed -E 's/^([^:]+):([0-9]+): error:.*/\1:\2/' | sort -u
