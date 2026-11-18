#!/bin/sh
# Grading dependencies: the urchin test runner (npm package urchin 0.0.5, sha1 4fddd7b0f83a131ca027c8126654324b3591d1fe, BSD
# licence in projects/shell-medium/urchin.LICENCE) that nvm's Makefile runs its suites with. The npm registry cannot be
# reached with the grading toolchain (no curl, no node), so the 6 KB script is kept in this directory and installed into
# node_modules/.bin (git-ignored, so it becomes the grading overlay).
set -e
mkdir -p node_modules/.bin
cp /project/urchin node_modules/.bin/urchin
chmod +x node_modules/.bin/urchin
# The test mocks contain node_modules directories whose names have spaces in their paths; git ignores them, and the driver's
# overlay step cannot copy quoted paths. They are part of the snapshot already, so stage them to take them out of the ignored list.
git add -f test
