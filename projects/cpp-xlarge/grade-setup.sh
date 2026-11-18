#!/bin/sh
# Grading dependencies of DuckDB, with network (nothing is fetched: every extension that is built is in the tree): the
# prebuilt tree. The build directory build/ (git-ignored, so it becomes the grading overlay) holds a complete Release
# build (-O1 -g0, no sanitizers, unity builds on, the in-tree extensions core_functions, parquet, json, icu) of the
# unittest runner with its C++ tests, at this snapshot's commit, so that check.sh only rebuilds what a patch touches.
# Setup and grading both run in /scratch/work, so the paths in CMakeCache.txt hold.
set -e
OVERRIDE_GIT_DESCRIBE=v2.0.0-0-gd54cbbe cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="-O1 -g0 -DNDEBUG" \
  -DENABLE_SANITIZER=OFF -DENABLE_UBSAN=OFF -DBUILD_BENCHMARKS=OFF > /tmp/cmake.log 2>&1 || { tail -40 /tmp/cmake.log; exit 1; }
make -C build -j 3 unittest loadable_extension_demo_loadable_extension > /tmp/make.log 2>&1 || { grep -E -B2 -A8 'error|Error' /tmp/make.log | head -80; tail -5 /tmp/make.log; exit 1; }
test -x build/test/unittest
