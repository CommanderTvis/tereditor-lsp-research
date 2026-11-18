#!/bin/sh
# Fail to pass and pass to pass: the test files the pull request changed.
set -e
sh /project/check.sh src/jsx/dom/index.test.tsx
