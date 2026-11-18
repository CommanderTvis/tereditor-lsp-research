#!/bin/sh
# Fail to pass and pass to pass: the test programs of the files the pull request changed (test_files in task.toml),
# with its versions of those files (held out), built with the project's CMake build and run through ctest.
set -e
progs=$(sed -n 's/^test_files = \[\(.*\)\]/\1/p' "${TASK_DIR:-/task}/task.toml" | tr -d '" ' | tr ',' '\n' | sed -n 's|^test/\(.*\)\.cc$|\1|p')
cmake -S . -B /tmp/build -DFMT_TEST=ON -DFMT_DOC=OFF -DCMAKE_BUILD_TYPE=Debug -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  > /tmp/cmake.log 2>&1 || { tail -50 /tmp/cmake.log; exit 1; }
for t in $progs; do
  cmake --build /tmp/build --target "$t" -j 3 > /tmp/build.log 2>&1 || { grep -E -A5 'error' /tmp/build.log | head -60; exit 1; }
done
ctest --test-dir /tmp/build --no-tests=error -R "^($(echo $progs | tr ' ' '|'))\$" --output-on-failure
