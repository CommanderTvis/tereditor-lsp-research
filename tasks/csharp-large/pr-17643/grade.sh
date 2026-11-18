#!/bin/sh
# Mined pull request: its fail-to-pass tests (f2p.txt, one test method or test class name per line) must run and pass,
# then every test of the project's test run (pass-to-pass) must pass.
set -e
export TEST_PROJECTS="Jellyfin.Server.Implementations.Tests"
f=$(sed -e '/^$/d' -e 's/^/FullyQualifiedName~/' "$TASK_DIR/f2p.txt" | paste -sd'|' -)
n=$(grep -c . "$TASK_DIR/f2p.txt")
out=$(TEST_VERBOSITY=n TEST_FILTER="($f)" sh /project/check.sh 2>&1) && rc=0 || rc=$?
echo "$out"
[ "$rc" = 0 ] || { echo "fail-to-pass tests failed"; exit 1; }
ran=$(echo "$out" | sed -n -e 's/.*Total tests: *\([0-9][0-9]*\).*/\1/p' -e 's/.*Total: *\([0-9][0-9]*\).*/\1/p' | tail -n1)
[ "${ran:-0}" -ge "$n" ] || { echo "expected at least $n fail-to-pass tests to run, ran ${ran:-0}"; exit 1; }
sh /project/check.sh
