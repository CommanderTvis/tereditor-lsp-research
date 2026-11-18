#!/bin/sh
# Build-and-test for hono at the commit being graded.
# - The pinned commit (vitest): type-check the sources and their tests (as `npm test` does), then the Node-hosted
#   vitest projects. Coverage and the workerd/fastly runtime projects are left out (no network, no extra runtimes).
# - Base commits of the mined pull requests (2022, jest with the miniflare environment): the whole jest suite, or
#   only the test files given as arguments (a task's grade.sh passes the affected modules' tests).
set -e
if [ -f jest.config.js ]; then
  npx jest --ci "$@"
else
  [ $# -gt 0 ] || set -- src
  npx tsc -p tsconfig.spec.json
  # A task's grade.sh may pass the test files of the affected modules; with none, the whole Node-hosted suite runs.
  npx vitest run --coverage.enabled=false --project main --project jsx-runtime-default --project jsx-runtime-dom "$@"
fi
