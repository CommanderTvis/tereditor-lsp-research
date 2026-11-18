#!/bin/sh
# writeFromReadableStreamDefaultReader is declared in src/internal/writeFromReadableStreamDefaultReader.ts only, and
# src/utils.ts neither declares nor re-exports it; then the type check and tests.
set -e
grep -qE '^export function writeFromReadableStreamDefaultReader\b' src/internal/writeFromReadableStreamDefaultReader.ts
if grep -rnE 'function\*? *writeFromReadableStreamDefaultReader\b' src --include='*.ts' | grep -v '^src/internal/writeFromReadableStreamDefaultReader.ts:'; then exit 1; fi
if grep -nE 'export[^;]*\bwriteFromReadableStreamDefaultReader\b' src/utils.ts; then exit 1; fi
sh /project/check.sh
