#!/bin/sh
# Build-and-test for click (src/ layout, not installed): import the package from src/ (catches syntax and name errors
# at import) and run the test suite.
set -e
export PYTHONPATH=/work/src
python -c "import click, click.testing, click.shell_completion, click.termui"
python -m pytest -q -p no:cacheprovider tests
