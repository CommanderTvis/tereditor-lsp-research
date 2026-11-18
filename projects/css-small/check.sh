#!/bin/sh
# Build-and-test for tabler (Sass): every top-level entry point of core/scss compiles to the same CSS as at the
# project's pinned commit (grade-setup.sh stored it in node_modules/.study-ref; every synthetic task is a
# behaviour-preserving refactoring), then the repository's SCSS unit tests (sass-true and the compile tests, vitest) pass.
# Mined tasks run their own tests (their grade.sh).
set -e
sh /project/compile.sh /tmp/check-out
ref=node_modules/.study-ref
[ -d "$ref" ] || { echo "check: no reference compilation (grade-setup.sh)" >&2; exit 1; }
diff -r "$ref" /tmp/check-out > /tmp/check.diff || { head -80 /tmp/check.diff; echo "check: compiled CSS differs" >&2; exit 1; }
echo "check: $(ls /tmp/check-out | grep -c '\.css$') entry points compile to identical CSS"
cd core && CI=1 node_modules/.bin/vitest run --config vitest.scss.config.mjs
