#!/bin/sh
# Mined pull request: its fail-to-pass test classes (f2p.txt, module and class per line) must run and pass, then every test of the
# modules the pull request's tests live in (pass-to-pass) must pass. Tests that fail in the grading sandbox for reasons that
# have nothing to do with the change (they read from the network, which the sandbox lacks) are listed in p2p-exclude.txt, one
# "class." (every test of the class) or "class.name" per line, taken from a run of the reference solution; any other failing test fails the task.
set -e
n=$(grep -c . "$TASK_DIR/f2p.txt")
[ "$n" -gt 0 ] || { echo "no fail-to-pass tests listed"; exit 1; }
run() {
  out=$(sh /project/check.sh "$@" 2>&1) && return 0
  printf '%s\n' "$out" | tail -60
  failed=$(printf '%s\n' "$out" | sed -n 's/^FAILED_TEST //p')
  [ -n "$failed" ] || return 1
  printf '%s\n' "$failed" | grep -vF -f "$TASK_DIR/p2p-exclude.txt" > /tmp/unexpected.txt || true
  [ ! -s /tmp/unexpected.txt ] || { echo "unexpected failures:"; cat /tmp/unexpected.txt; return 1; }
}
run :core:test --tests 'org.jetbrains.kotlinx.dataframe.api.SortTests' --tests 'org.jetbrains.kotlinx.dataframe.testSets.person.DataFrameTests' --tests 'org.jetbrains.kotlinx.dataframe.testSets.weather.SeriesTests' || { echo "fail-to-pass tests failed"; exit 1; }
run :core:test
