#!/bin/sh
set -e
PY=$HOME/venv/bin/python
$PY -m compileall -q mypy
$PY -m pytest -q -p no:cacheprovider test 2>/dev/null || $PY -m pytest -q -p no:cacheprovider mypy/test
