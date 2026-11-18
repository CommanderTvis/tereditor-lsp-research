#!/bin/sh
# check.sh [online] [gradle tasks...]: compiles the main and test code of the library modules (core, dataframe-json, -csv,
# -arrow, -excel, -jupyter, -geo, samples, common-test-utils), offline, then runs the given tasks (a task's grade.sh names the
# tests it needs, e.g. :core:test --tests ...). The JDBC module (Testcontainers) and the compiler plugin are not built.
off=--offline; [ "${1:-}" = online ] && { off=; shift; }
G="./gradlew --no-daemon $off -q --no-configuration-cache --build-cache --continue -Porg.gradle.java.installations.auto-download=false -Dorg.gradle.jvmargs=-Xmx2500m"
$G :core:testClasses :dataframe-json:testClasses :dataframe-csv:testClasses :dataframe-arrow:testClasses :dataframe-excel:testClasses :samples:testClasses :common-test-utils:testClasses "$@" > /tmp/gradle.log 2>&1
rc=$?
tail -80 /tmp/gradle.log
if [ $rc -ne 0 ]; then
  # -q hides test names: list the failed test cases from the result files, one "FAILED_TEST <class>.<name>" line each (grade.sh
  # compares them with the task's p2p-exclude.txt)
  find . -path '*/build/test-results/*' -name '*.xml' | xargs grep -l '<failure\|<error' 2>/dev/null | while read -r f; do
    awk '/<testcase /{ match($0,/ name="[^"]*"/); n=substr($0,RSTART+7,RLENGTH-8); match($0,/ classname="[^"]*"/); c=substr($0,RSTART+12,RLENGTH-13); name=c "." n } /<(failure|error)/{ if (name!="") print "FAILED_TEST " name; name="" }' "$f"
  done
fi
exit $rc
