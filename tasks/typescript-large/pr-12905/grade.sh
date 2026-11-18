#!/bin/sh
# Fail to pass and pass to pass: the test files the pull request changed.
set -e
sh /project/check.sh test/functional/query-builder/composite-key-hydration/composite-floating-key-hydration.test test/functional/query-builder/composite-key-hydration/composite-key-hydration.test
