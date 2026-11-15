#!/bin/sh
# Build-and-test for toolz: import the package (catches syntax and name errors at import) and run the test suite.
# test_has_version needs an installed distribution (package metadata), which a source tree does not have.
set -e
python -c "import toolz, toolz.curried, tlz"
python -m pytest -q -p no:cacheprovider toolz --deselect toolz/tests/test_package.py::test_has_version
