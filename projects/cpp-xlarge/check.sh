#!/bin/sh
# Build for DuckDB, offline: the same configuration as grade-setup.sh, so make only rebuilds what the patch (and the
# held-out tests) changed against the prebuilt build/ directory of the grading overlay. The loadable_extension_demo_loadable_extension
# target is built too: some C++ tests load it.
set -e
OVERRIDE_GIT_DESCRIBE=v2.0.0-0-gd54cbbe cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="-O1 -g0 -DNDEBUG" \
  -DENABLE_SANITIZER=OFF -DENABLE_UBSAN=OFF -DBUILD_BENCHMARKS=OFF > /tmp/cmake.log 2>&1 || { tail -40 /tmp/cmake.log; exit 1; }
make -C build -j 3 unittest loadable_extension_demo_loadable_extension > /tmp/make.log 2>&1 || { grep -E -B2 -A8 'error|Error' /tmp/make.log | head -80; tail -5 /tmp/make.log; exit 1; }
