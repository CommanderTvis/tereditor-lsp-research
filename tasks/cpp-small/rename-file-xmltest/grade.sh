#!/bin/sh
# Old path gone, new path present; the build descriptions (CMake, test/CMake, Makefile, Meson) and the C++ sources
# name only the new file; make resolves the xmltest target's prerequisites; then the project's build and tests (whose
# CMake build compiles the renamed file).
set -e
test ! -e xmltest.cpp
test -f tinyxml2_test.cpp
for f in CMakeLists.txt test/CMakeLists.txt Makefile meson.build; do
  grep -q 'tinyxml2_test\.cpp' "$f"
  if grep -n 'xmltest\.cpp' "$f"; then exit 1; fi
done
if git ls-files -co --exclude-standard '*.h' '*.cpp' | xargs grep -n 'xmltest\.cpp'; then exit 1; fi
make -n xmltest > /dev/null
sh /project/check.sh
