#!/bin/sh
# Derives oracle.txt with javac, not a language server. Compile every main and test source of the gson module (with
# its generated sources) twice: unmodified, and with the Class<T> overload of Gson.getAdapter renamed. Errors that
# appear only after the rename are its call sites; each is mapped to the line of the call where `getAdapter(` appears
# (that line or the nearest one above). Run in the grade image: sh derive-oracle.sh > oracle.txt
set -e
rm -rf /tmp/o && cp -a /study/snapshot /tmp/o && cd /tmp/o
mvn -B -q -o -pl gson generate-sources dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt -Dmdep.includeScope=test >/dev/null
find gson/src/main/java gson/src/test/java gson/target/generated-sources -name '*.java' ! -name module-info.java > /tmp/srcs.txt
compile() { rm -rf /tmp/classes && mkdir -p /tmp/classes
  javac -proc:none -Xmaxerrs 10000 -nowarn -d /tmp/classes -cp "$(cat /tmp/cp.txt)" @/tmp/srcs.txt 2>&1 |
    grep -E '^[^ ]+\.java:[0-9]+: error' | sed -E 's/^([^:]+):([0-9]+):.*/\1 \2/' | sort -u; }
compile > /tmp/before.txt
# Line 407 holds `public <T> TypeAdapter<T> getAdapter(Class<T> type) {` at the pinned commit.
sed -n '407p' gson/src/main/java/com/google/gson/Gson.java | grep -q 'getAdapter(Class<T> type)'
sed -i '407s/getAdapter(Class<T> type)/getAdapter__oracle(Class<T> type)/' gson/src/main/java/com/google/gson/Gson.java
compile > /tmp/after.txt
echo "errors before: $(wc -l < /tmp/before.txt), after: $(wc -l < /tmp/after.txt)" >&2
comm -13 /tmp/before.txt /tmp/after.txt |
while read -r f l; do
  awk -v l="$l" 'NR<=l && /getAdapter\(/ {hit=NR} NR==l {if (hit) print hit; else print "UNMAPPED"; exit}' "$f" | sed "s|^|$f:|"
done | sort -u
