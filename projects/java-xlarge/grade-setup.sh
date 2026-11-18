#!/bin/sh
# Dependencies for grading, resolved once with network: the wrapper distribution, the build's plugins, and what every
# module needs to compile and what lucene:core needs to run tests (the randomized test runner included). Compile errors
# are fatal; test failures are not.
# Lucene main needs JDK 25 to 27 (the default JDK 21 is refused by its build); 10.6.0 builds with it too.
export JAVA_HOME=$(study-jdk25)
set -e
t=$(date +%s)
./gradlew --no-daemon -q --console=plain compileTestJava
echo "grade-setup compile of all modules: $(( $(date +%s) - t )) s" >&2
t=$(date +%s)
./gradlew --no-daemon --console=plain :lucene:core:test --tests 'org.apache.lucene.util.TestBitUtil' > /tmp/gradle-setup.log 2>&1 || true
tail -5 /tmp/gradle-setup.log
echo "grade-setup first test: $(( $(date +%s) - t )) s" >&2
