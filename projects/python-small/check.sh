#!/bin/sh
# Build-and-test for pydantic-extra-types: byte-compile, import the package, run the test suite with the grading home's
# virtual environment (grade-setup.sh).
set -e
export TZ=UTC
PY=$HOME/venv/bin/python
$PY -m compileall -q pydantic_extra_types > /dev/null
$PY -c "import pydantic_extra_types, pydantic_extra_types.country, pydantic_extra_types.color"
$PY -m pytest -q -p no:cacheprovider tests
