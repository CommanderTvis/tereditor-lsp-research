#!/bin/sh
# Mined pull request: its fail-to-pass tests (f2p.txt, one test method name per line, matched as patterns) must run and pass,
# then every test of the selected test projects (pass-to-pass) must pass.
set -e
export TEST_PROJECTS="Microsoft.Data.Sqlite.Tests"
f=$(sed -e '/^$/d' -e 's/^/*/' -e 's/$/*/' "$TASK_DIR/f2p.txt" | paste -sd' ' -)
n=$(grep -c . "$TASK_DIR/f2p.txt")
out=$(TEST_VERBOSITY=normal TEST_FILTER="$f" sh /project/check.sh 2>&1) && rc=0 || rc=$?
echo "$out"
[ "$rc" = 0 ] || { echo "fail-to-pass tests failed"; exit 1; }
ran=$(echo "$out" | sed -n -e 's/.*[Tt]otal tests: *\([0-9][0-9]*\).*/\1/p' -e 's/.*[Tt]otal: *\([0-9][0-9]*\).*/\1/p' | awk '{s+=$1} END{print s+0}')
[ "${ran:-0}" -ge "$n" ] || { echo "expected at least $n fail-to-pass tests to run, ran ${ran:-0}"; exit 1; }
sh /project/check.sh
