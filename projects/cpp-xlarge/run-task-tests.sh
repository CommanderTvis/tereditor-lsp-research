#!/bin/sh
# Runs the tests of the files a mined task changed (test_files in /task/task.toml, held-out versions already in the
# tree) with the unittest runner built by check.sh: an SQL logic test file (*.test, *.test_slow) is run by path, a C++
# test file by the names of its TEST_CASEs. Fails when a test fails or when nothing was run.
set -e
files=$(sed -n 's/^test_files = \[\(.*\)\]/\1/p' "${TASK_DIR:-/task}/task.toml" | tr -d '" ' | tr ',' '\n')
ran=0
for f in $files; do
  case "$f" in
    *.test|*.test_slow|*.test_coverage) build/test/unittest "$f" || exit 1; ran=$((ran + 1)) ;;
    *.cpp)
      sed -n 's/^[[:space:]]*TEST_CASE("\([^"]*\)".*/\1/p' "$f" | while IFS= read -r name; do
        build/test/unittest "$name" || exit 1
      done || exit 1
      ran=$((ran + 1)) ;;
    *) ;;
  esac
done
[ "$ran" -gt 0 ] || { echo "no runnable test file in: $files"; exit 1; }
