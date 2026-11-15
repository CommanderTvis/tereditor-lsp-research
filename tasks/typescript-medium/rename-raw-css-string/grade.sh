#!/bin/sh
# The old name is gone from src/ and the new one is declared in common.ts; then the type check and the tests
# (including the hidden test, which imports rawCss from both public entry points).
set -e
if grep -rnw rawCssString src; then exit 1; fi
grep -qE 'export const rawCss\b' src/helper/css/common.ts
sh /project/check.sh
