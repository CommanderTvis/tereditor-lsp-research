#!/bin/sh
# Fail to pass and pass to pass: the test programs of the files the pull request changed (core-test locale-test), with its
# versions of those files (held out), built with the project's CMake build and run through ctest.
set -e
cmake -S . -B /tmp/build -DFMT_TEST=ON -DFMT_DOC=OFF -DCMAKE_BUILD_TYPE=Debug -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  > /tmp/cmake.log 2>&1 || { tail -50 /tmp/cmake.log; exit 1; }
for t in core-test locale-test; do
  cmake --build /tmp/build --target "$t" -j 4 > /tmp/build.log 2>&1 || { grep -E -A5 'error' /tmp/build.log | head -60; exit 1; }
done
ctest --test-dir /tmp/build --no-tests=error -R '^(core-test|locale-test)$' --output-on-failure
