#!/bin/sh
# mypy's tests need mypy's own runtime dependencies and the test tools. The same set serves the pinned commit and the
# older base commits of the mined pull requests (CPython 3.12); optional ones are best effort. Before pytest 7 support
# (mypy/test/data.py calls the removed Collector._prunetraceback) a failing test aborts the whole session under a newer
# pytest, so such commits get pytest 6.2.5 (which still runs on CPython 3.12).
set -e
python -m venv "$HOME/venv"
P="$HOME/venv/bin/python -m pip install -q --disable-pip-version-check --no-input"
if grep -q _prunetraceback mypy/test/data.py 2>/dev/null; then T="pytest==6.2.5 pytest-xdist==2.5.0 py"; else T="pytest==8.3.5 pytest-xdist"; fi
$P $T attrs filelock psutil typing_extensions mypy_extensions tomli setuptools
$P pathspec lxml || true
$P librt ast-serialize || true
