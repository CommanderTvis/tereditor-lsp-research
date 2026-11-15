#!/bin/sh
# Build-and-test for fmt, offline: the CMake build with its tests (bundled googletest, Debug) and every test through
# ctest. CMAKE_POLICY_VERSION_MINIMUM lets CMake 4 configure the older base commits of mined tasks.
set -e
cmake -S . -B /tmp/build -DFMT_TEST=ON -DFMT_DOC=OFF -DCMAKE_BUILD_TYPE=Debug -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  > /tmp/cmake.log 2>&1 || { tail -50 /tmp/cmake.log; exit 1; }
cmake --build /tmp/build -j 4 > /tmp/build.log 2>&1 || { grep -E -A5 'error|Error' /tmp/build.log | head -80; exit 1; }
ctest --test-dir /tmp/build -j 4 --output-on-failure
