#!/bin/sh
# astroid's test tools and the optional packages its brain tests import, into the grading home's virtual environment
# (CPython 3.12). PyQt6 is left out (large, needs system libraries); its brain test skips. astroid itself is imported
# from the work tree.
set -e
python -m venv "$HOME/venv"
"$HOME/venv/bin/python" -m pip install -q --disable-pip-version-check --no-input \
  pytest coverage pytest-cov attrs numpy python-dateutil regex 'setuptools<82' six 'urllib3>1,<2' 'typing_extensions>=4.4.0'
