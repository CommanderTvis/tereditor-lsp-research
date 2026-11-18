#!/bin/sh
# Fail to pass and pass to pass: build the unittest runner (incrementally, against the prebuilt build/ directory), then
# run every test of the test files the pull request changed, with its versions of them (held out).
set -e
sh /project/check.sh
sh /project/run-task-tests.sh
