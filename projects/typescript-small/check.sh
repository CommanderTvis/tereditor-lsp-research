#!/bin/sh
# Build-and-test for node-server at the commit being graded: type-check sources and tests, then vitest (the whole Node
# suite, or only the test files given as arguments; a task's grade.sh passes the affected tests).
set -e
npx tsc --noEmit
npx vitest run "$@"
