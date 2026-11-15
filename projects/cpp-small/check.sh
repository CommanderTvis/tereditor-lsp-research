#!/bin/sh
# Build-and-test for tinyxml2, offline: the CMake build (library and xmltest, Debug), xmltest through ctest (passes on
# ", Fail 0"), and contrib/html5-printer.cpp, which no build target compiles, checked for syntax against the library.
set -e
cmake -S . -B /tmp/build -DCMAKE_BUILD_TYPE=Debug -Dtinyxml2_BUILD_TESTING=ON > /tmp/cmake.log 2>&1 || { cat /tmp/cmake.log; exit 1; }
cmake --build /tmp/build -j 4
ctest --test-dir /tmp/build --output-on-failure
c++ -fsyntax-only -I. contrib/html5-printer.cpp
