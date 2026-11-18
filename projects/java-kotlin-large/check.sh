#!/bin/sh
# check.sh [online]: builds and tests offline (Maven, JDK 21). MODULES (default embabel-agent-api) are built with the modules
# they depend on (-pl ... -am); TEST_FILTER, a surefire -Dtest expression, restricts the run (the fail-to-pass tests of a mined
# task). The tests that need Docker (Testcontainers) are skipped by the project's own switch.
export SKIP_TESTCONTAINER_TESTS=true MAVEN_OPTS=-Xmx2g
off=-o; [ "${1:-}" = online ] && off=
# Stale class files of moved or deleted sources must not survive: build from clean target directories.
find . -name target -type d -prune -exec rm -rf {} + 2>/dev/null
if [ -n "${TEST_FILTER:-}" ]; then
  mvn -B -q $off -pl "${MODULES:-embabel-agent-api}" -am test -Dsurefire.failIfNoSpecifiedTests=false -Dtest="$TEST_FILTER" > /tmp/mvn.log 2>&1
else
  mvn -B -q $off -pl "${MODULES:-embabel-agent-api}" -am test > /tmp/mvn.log 2>&1
fi
rc=$?
tail -60 /tmp/mvn.log
exit $rc
