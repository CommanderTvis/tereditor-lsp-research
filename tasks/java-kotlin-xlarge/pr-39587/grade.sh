#!/bin/sh
# Mined pull request: its fail-to-pass test classes (f2p.txt: Gradle project path and class per line) must run and pass,
# then every test in the packages of those classes (pass-to-pass) must pass.
set -e
n=$(grep -c . "$TASK_DIR/f2p.txt")
[ "$n" -gt 0 ] || { echo "no fail-to-pass tests listed"; exit 1; }
sh /project/check.sh f2p "$TASK_DIR/f2p.txt" || { echo "fail-to-pass tests failed"; exit 1; }
sh /project/check.sh packages "$TASK_DIR/f2p.txt"
