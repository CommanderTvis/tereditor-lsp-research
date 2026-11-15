#!/bin/sh
# The old name is gone from the C++ sources, the held-out program (which uses only the new name and asserts at compile
# time that no node class still declares the old one) builds and passes, then the project's build and tests.
set -e
if git ls-files '*.h' '*.cpp' | xargs grep -n '\bShallowEqual\b'; then exit 1; fi
c++ -std=c++11 -I. study_hidden_rename.cpp tinyxml2.cpp -o /tmp/study_hidden_rename
/tmp/study_hidden_rename
sh /project/check.sh
