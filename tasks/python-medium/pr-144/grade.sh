#!/bin/sh
# Mined pull request: its fail-to-pass tests, then the pass-to-pass tests of the test files it changed (the ones that
# pass at its base commit and after its merge with CPython 3.12). Test ids are listed one per line.
set -e
PY=python; [ -x "$HOME/venv/bin/python" ] && PY=$HOME/venv/bin/python
run() { [ -s "$1" ] || return 0; tr '\n' '\0' < "$1" | xargs -0 "$PY" -m pytest -p no:cacheprovider -q; }
run "$TASK_DIR/fail_to_pass.txt"
run "$TASK_DIR/pass_to_pass.txt"
