#!/bin/sh
# Build-and-test for hono: type-check the sources and their tests (as `npm test` does), then the Node-hosted vitest
# projects. Coverage and the workerd/fastly runtime projects are left out (no network, no extra runtimes).
set -e
npx tsc -p tsconfig.spec.json
npx vitest run --coverage.enabled=false --project main --project jsx-runtime-default --project jsx-runtime-dom
