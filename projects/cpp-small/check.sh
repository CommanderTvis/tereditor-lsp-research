#!/bin/sh
# Build-and-test for MD4C, offline: the CMake build (library, HTML renderer, md2html), then every test suite through
# scripts/run-tests.py: the CommonMark spec and each extension's spec (test/*.txt, example by example through md2html),
# regressions and coverage, and the pathological-input tests. Python 3 comes from the grading toolchain.
set -e
root=$PWD
cmake -S . -B /tmp/build -DCMAKE_BUILD_TYPE=Release > /tmp/cmake.log 2>&1 || { cat /tmp/cmake.log; exit 1; }
cmake --build /tmp/build -j 4 > /tmp/build.log 2>&1 || { grep -E -B2 -A6 'error' /tmp/build.log | head -60; exit 1; }
cd /tmp/build
python3 "$root/scripts/run-tests.py" > /tmp/tests.log 2>&1 || { grep -E -B30 'FAILED|failed|error' /tmp/tests.log | grep -v PASSED | head -120; tail -5 /tmp/tests.log; exit 1; }
tail -n 3 /tmp/tests.log
