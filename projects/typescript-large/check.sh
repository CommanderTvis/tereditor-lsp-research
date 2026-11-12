#!/bin/sh
# Build-and-test for NestJS: build every package (tsc -b, as `npm run build`), type-check the unit specs, run them.
set -e
npx tsc -b packages
npx tsc -p tsconfig.spec.json --noEmit
npx vitest run
