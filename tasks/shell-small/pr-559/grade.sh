#!/bin/sh
# Mined pull request: its held-out test files are in place. The whole suite of the base commit is run by the work
# tree's bin/bats: the fail-to-pass tests are the ones in the files F2P (the pull request's tests) that fail at the
# base commit, the rest is pass to pass. Every planned test must run, and only the tests listed in KNOWN may fail (they fail at the base commit and with the reference solution alike in the grading
# sandbox, for reasons unrelated to the change).
F2P='test/tap13-formatter.bats'
KNOWN='test works even if PATH is reset|junit formatter: escapes xml special chars|junit does not mark tests with FD 3 output as failed (issue #360)|bats_load_library requires BATS_LIB_PATH to be set|Timing printout shows milliseconds|syntax errors in setup_suite.bash are reported and lead to non zero exit code'
out=/tmp/suite.tap
bin/bats --tap test > $out 2>&1; cat $out
plan=$(sed -n 's/^1\.\.\([0-9]*\)$/\1/p' $out | head -n1)
ran=$(grep -cE '^(not )?ok [0-9]+' $out)
[ -n "$plan" ] && [ "$ran" -eq "$plan" ] || { echo "grade: the suite ran $ran of ${plan:-?} tests"; exit 1; }
bad=$(grep -E '^not ok [0-9]+ ' $out | sed -E 's/^not ok [0-9]+ //; s/ # .*$//' | while IFS= read -r t; do
  printf '%s\n' "$KNOWN" | tr '|' '\n' | grep -Fxq "$t" || echo "$t"
done)
[ -z "$bad" ] || { echo "grade: pass-to-pass failures:"; echo "$bad"; exit 1; }
echo "grade: ok"
