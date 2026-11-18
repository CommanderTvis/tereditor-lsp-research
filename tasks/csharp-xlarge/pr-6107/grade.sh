#!/bin/sh
# Mined pull request: its fail-to-pass tests (f2p.txt, one test method name per line) must run and pass on SQLite.MS, then every
# test of the test classes the pull request touched (classes.txt, one class name per line) must pass (pass to pass).
set -e
f=$(sed -e '/^$/d' -e 's/^/FullyQualifiedName~/' "$TASK_DIR/f2p.txt" | paste -sd'|' -)
c=$(sed -e '/^$/d' -e 's/^/FullyQualifiedName~/' "$TASK_DIR/classes.txt" | paste -sd'|' -)
n=$(grep -c . "$TASK_DIR/f2p.txt")
out=$(TEST_FILTER="($f)" sh /project/check.sh 2>&1) && rc=0 || rc=$?
echo "$out"
[ "$rc" = 0 ] || { echo "fail-to-pass tests failed"; exit 1; }
ran=$(echo "$out" | sed -n 's/.*[Tt]otal: *\([0-9][0-9]*\).*/\1/p' | tail -n1)
[ "${ran:-0}" -ge "$n" ] || { echo "expected at least $n fail-to-pass tests to run, ran ${ran:-0}"; exit 1; }
TEST_FILTER="($c)" sh /project/check.sh
