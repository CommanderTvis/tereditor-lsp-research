#!/bin/sh
# Mined pull request: its fail-to-pass test classes (f2p.txt, one "<gradle project path> <class>" per line) must run and
# pass, then every test of the checked modules (pass-to-pass) must pass.
set -e
n=$(grep -c . "$TASK_DIR/f2p.txt")
[ "$n" -gt 0 ] || { echo "no fail-to-pass tests listed"; exit 1; }
TEST_FILTER=$(sed -e '/^$/d' "$TASK_DIR/f2p.txt") sh /project/check.sh || { echo "fail-to-pass tests failed"; exit 1; }
sh /project/check.sh
