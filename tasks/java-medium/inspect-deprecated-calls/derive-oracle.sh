#!/bin/sh
# Run in a JDK 21 + Maven environment with the gson snapshot at $1 (copied, not modified): prints, per file of the gson
# module, whether it calls a @Deprecated method of the gson module's main code, by compiler mutation.
set -e
src=${1:-/study/snapshot}
rm -rf /tmp/o && cp -a "$src" /tmp/o && cd /tmp/o
mvn -B -q -o -pl gson generate-sources dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt -Dmdep.includeScope=test >/dev/null
find gson/src/main/java gson/src/test/java gson/target/generated-sources -name '*.java' ! -name module-info.java | sort > /tmp/srcs.txt
compile() { rm -rf /tmp/classes && mkdir -p /tmp/classes
  javac -proc:none -Xmaxerrs 100000 -nowarn -d /tmp/classes -cp "$(cat /tmp/cp.txt)" @/tmp/srcs.txt 2>&1 |
    grep -E '^[^ ]+\.java:[0-9]+: error' | sed -E 's/^([^:]+):([0-9]+):.*/\1/' | sort -u; }
compile > /tmp/before.txt
# Every method (not constructor) annotated @Deprecated in gson/src/main/java: the first line after the annotation that
# declares `<type> name(` gets `name` renamed to `name__deprecated`.
: > /tmp/declaring.txt
for f in $(grep -rl '@Deprecated' gson/src/main/java); do
  awk '
    /^[[:space:]]*@Deprecated/ {pending=1; print; next}
    pending && /^[[:space:]]*(public|protected|private|static|final|synchronized|abstract|<)[^=;]*[[:space:]][a-zA-Z_][a-zA-Z0-9_]*\(/ {
      if (match($0, /[a-zA-Z_][a-zA-Z0-9_]*\(/)) {
        name = substr($0, RSTART, RLENGTH - 1)
        pre = substr($0, 1, RSTART - 1)
        if (pre ~ /[a-zA-Z>\]][[:space:]]+$/ && pre !~ /^[[:space:]]*(public|protected|private)[[:space:]]+$/) {
          $0 = pre name "__deprecated(" substr($0, RSTART + RLENGTH); hit = 1
          print FILENAME ": " name > "/dev/stderr"
        }
      }
      pending = 0
    }
    {print}
  ' "$f" > /tmp/m.java 2>>/tmp/declaring.txt && cp /tmp/m.java "$f"
done
cat /tmp/declaring.txt >&2
compile > /tmp/after.txt
echo "files with errors before: $(wc -l < /tmp/before.txt), after: $(wc -l < /tmp/after.txt)" >&2
comm -13 /tmp/before.txt /tmp/after.txt
