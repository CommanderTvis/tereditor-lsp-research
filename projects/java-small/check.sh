#!/bin/sh
# Build and test offline: the unit tests of every module and the @QuarkusTest classes of the integration-test modules
# (skipSurefireTests=false; the project's CI runs them in its integration-test workflow). TEST_FILTER, a surefire -Dtest
# expression, restricts the run (the fail-to-pass tests of a mined task).
if [ -n "${TEST_FILTER:-}" ]; then
  mvn -B -q -o test -DskipSurefireTests=false -Dsurefire.failIfNoSpecifiedTests=false -Dtest="$TEST_FILTER" > /tmp/mvn.log 2>&1
else
  mvn -B -q -o test -DskipSurefireTests=false > /tmp/mvn.log 2>&1
fi
rc=$?
tail -60 /tmp/mvn.log
exit $rc
