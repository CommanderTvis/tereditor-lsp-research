#!/bin/sh
# Fail to pass and pass to pass: the project's whole build and test run (every spec, regression, coverage and
# pathological suite through scripts/run-tests.py) with the pull request's versions of its test files (held out).
set -e
sh /project/check.sh
