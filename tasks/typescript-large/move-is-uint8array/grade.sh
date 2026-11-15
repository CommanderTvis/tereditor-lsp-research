#!/bin/sh
# isUint8Array is declared in src/util/guards/isUint8Array.ts only and Uint8ArrayUtils.ts does not re-export it; then
# the package compiles and the unit tests pass (including the hidden test, which imports the new module).
set -e
p=packages/typeorm/src/util
grep -qE '^export (const|function) isUint8Array\b' $p/guards/isUint8Array.ts
if grep -rnE '(const|function) isUint8Array\b' packages/typeorm/src --include='*.ts' | grep -v "^$p/guards/isUint8Array.ts:"; then exit 1; fi
if grep -nE 'export[^;]*\bisUint8Array\b' $p/Uint8ArrayUtils.ts; then exit 1; fi
sh /project/check.sh test/unit
