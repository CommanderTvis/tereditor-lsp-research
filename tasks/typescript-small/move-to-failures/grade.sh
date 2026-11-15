#!/bin/sh
# toFailures is declared in src/internal/toFailures.ts only, and src/utils.ts neither declares nor re-exports it;
# then the build and tests.
set -e
grep -qE '^export function\* *toFailures\b' src/internal/toFailures.ts
if grep -rnE 'function\*? *toFailures\b' src --include='*.ts' | grep -v '^src/internal/toFailures.ts:'; then exit 1; fi
if grep -nE 'export[^;]*\btoFailures\b' src/utils.ts; then exit 1; fi
sh /project/check.sh
