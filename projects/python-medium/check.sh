#!/bin/sh
# Build-and-test for astroid: byte-compile, import the package, run the test suite with the grading home's virtual
# environment (grade-setup.sh).
set -e
PY=$HOME/venv/bin/python
$PY -m compileall -q astroid > /dev/null
$PY -c "import astroid, astroid.nodes, astroid.brain.brain_builtin_inference"
$PY -m pytest -q -p no:cacheprovider tests
