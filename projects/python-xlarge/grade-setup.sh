#!/bin/sh
set -e
python -m venv "$HOME/venv"
"$HOME/venv/bin/python" -m pip install -q --disable-pip-version-check --no-input pytest==8.3.5
