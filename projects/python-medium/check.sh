#!/bin/sh
# Build-and-test for rich: byte-compile the package and the examples (syntax errors), import the main modules (name
# and import errors), then run the test suite, with the grading home's virtual environment (grade-setup.sh).
set -e
PY=$HOME/venv/bin/python
$PY -m compileall -q rich examples > /dev/null
$PY -c "import rich, rich.console, rich.markdown, rich.progress, rich.traceback, rich.live, rich.pretty, rich.table"
# test_brokenpipeerror runs `which`, which the grading sandbox does not have.
$PY -m pytest -q -p no:cacheprovider tests --deselect tests/test_console.py::test_brokenpipeerror
