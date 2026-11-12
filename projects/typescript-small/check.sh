#!/bin/sh
# Build-and-test for superstruct: type-check the library and the tests (as `npm run test:types` does), then vitest.
set -e
npx tsc --noEmit
npx tsc --project ./test/tsconfig.json --noEmit
npx vitest run
