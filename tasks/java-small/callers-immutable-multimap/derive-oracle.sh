#!/bin/sh
# Derives oracle.txt from bytecode, not a language server: compile the main sources with javac (through the project's
# build, Error Prone dropped as in check.sh), dump every class with javap, and walk the call graph backwards from
# Util.immutableMultimap with callgraph.py. Run with JDK 21, Maven and Python 3 in a copy of the snapshot:
#   sh derive-oracle.sh /path/to/task > oracle.txt
set -e
task=$1
. "$task/../../../projects/java-small/pom-jdk21.sh"
mvn -B -q -DskipTests compile >&2
(cd target/classes && javap -c -p -s $(find . -name '*.class' | sort)) > /tmp/javap.txt
python3 "$task/callgraph.py" /tmp/javap.txt --callers com.squareup.javapoet.Util.immutableMultimap
