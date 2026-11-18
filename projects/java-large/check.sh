#!/bin/sh
# Build and test jackson-databind offline. TEST_FILTER, a surefire -Dtest expression, restricts the run (the
# fail-to-pass tests of a mined task).
if [ -n "${TEST_FILTER:-}" ]; then
  mvn -B -q -o test -Dsurefire.failIfNoSpecifiedTests=false -Dtest="$TEST_FILTER" > /tmp/mvn.log 2>&1
else
  mvn -B -q -o test > /tmp/mvn.log 2>&1
fi
rc=$?
tail -60 /tmp/mvn.log
exit $rc
