#!/bin/sh
# Build and test offline, with Gradle (lucene's randomized test runner).
#   check.sh compile       compiles main and test code of every module.
#   check.sh f2p FILE      FILE holds lines "<module> <test class>", e.g. "lucene:core org.apache.lucene.index.TestFoo":
#                          runs just those classes (the fail-to-pass tests of a task).
#   check.sh modules M...  runs every test of the given modules, e.g. lucene:core (the pass-to-pass tests).
# The log of the last Gradle run is in /tmp/gradle.log (its tail is printed).
# Lucene main needs JDK 25 to 27 (the default JDK 21 is refused by its build); 10.6.0 builds with it too.
export JAVA_HOME=$(study-jdk25)
mode=$1; shift
args=""
case "$mode" in
  compile) args="compileTestJava" ;;
  f2p)
    for m in $(awk '{print $1}' "$1" | sort -u); do
      args="$args :$m:test"
      for c in $(awk -v m="$m" '$1==m {print $2}' "$1"); do args="$args --tests $c"; done
    done ;;
  modules) for m in "$@"; do args="$args :$m:test"; done ;;
esac
./gradlew --offline --no-daemon --console=plain $args > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
