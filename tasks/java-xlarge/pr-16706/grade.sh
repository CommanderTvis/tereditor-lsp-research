#!/bin/sh
# Mined pull request: its fail-to-pass test classes (f2p.txt: module and class per line) must run and pass, then every
# test of the module(s) they live in (pass-to-pass) must pass.
set -e
n=$(grep -c . "$TASK_DIR/f2p.txt")
[ "$n" -gt 0 ] || { echo "no fail-to-pass tests listed"; exit 1; }
sh /project/check.sh f2p "$TASK_DIR/f2p.txt" || { echo "fail-to-pass tests failed"; exit 1; }
sh /project/check.sh modules $(awk '{print $1}' "$TASK_DIR/f2p.txt" | sort -u)
