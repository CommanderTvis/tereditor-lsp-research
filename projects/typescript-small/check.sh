#!/bin/sh
# Build-and-test for superstruct, as its own `test` script does at the commit being graded:
# - since the switch to npm and vitest (the pinned commit): type-check the library and the tests, then vitest;
# - before it (the base commits of the mined pull requests, yarn and mocha): emit the declarations the tests import,
#   type-check, build the CommonJS bundle the tests load, then mocha.
set -e
if [ -f test/register.cjs ]; then
  npx tsc --emitDeclarationOnly --declarationMap --outDir ./lib
  npx tsc --noEmit
  npx tsc --project ./test/tsconfig.json --noEmit
  npx rollup --config ./config/rollup-cjs.js
  npx mocha --require ./test/register.cjs --require source-map-support/register ./test/index.ts
else
  npx tsc --noEmit
  npx tsc --project ./test/tsconfig.json --noEmit
  npx vitest run
fi
