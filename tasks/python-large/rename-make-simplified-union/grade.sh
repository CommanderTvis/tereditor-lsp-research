#!/bin/sh
# Build-and-test for a mypy refactoring: byte-compile, import every module of the package (name and import errors), then
# a representative subset of mypy's own tests (the whole suite takes too long to run for every grade).
set -e
PY=$HOME/venv/bin/python
$PY -m compileall -q mypy
$PY - <<'EOF'
import importlib, pkgutil, mypy
bad = []
for m in pkgutil.walk_packages(mypy.__path__, "mypy."):
    if ".typeshed" in m.name or m.name.endswith("__main__"):
        continue
    try:
        importlib.import_module(m.name)
    except Exception as e:
        bad.append((m.name, repr(e)))
assert not bad, bad
EOF
$PY -m pytest -q -p no:cacheprovider -n3 mypy/test/testtypes.py mypy/test/testsubtypes.py mypy/test/testsemanal.py mypy/test/testtransform.py mypy/test/test_study_hidden.py
$PY -m pytest -q -p no:cacheprovider -n3 mypy/test/testcheck.py -k "check-unions or check-isinstance or check-basic or check-functions or check-generics or check-overloading or check-narrowing"
