#!/bin/sh
# Build-and-test for carbon (Sass): every Sass entry point (compile.sh) of the work tree must compile to the same CSS as
# at the project's pinned commit, whose outputs grade-setup.sh stored in node_modules/.study-ref (every synthetic task
# is a behaviour-preserving refactoring). Mined tasks run their own Jest tests (their grade.sh).
set -e
sh /project/compile.sh /tmp/check-out
ref=node_modules/.study-ref
[ -d "$ref" ] || { echo "check: no reference compilation (grade-setup.sh)" >&2; exit 1; }
rm -f /tmp/check-out/.entries
diff -r "$ref" /tmp/check-out > /tmp/check.diff || { head -80 /tmp/check.diff; echo "check: compiled CSS differs" >&2; exit 1; }
echo "check: $(ls /tmp/check-out | grep -c '\.css$') entry points compile to identical CSS"
