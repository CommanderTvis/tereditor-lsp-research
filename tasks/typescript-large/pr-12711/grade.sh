#!/bin/sh
# Fail to pass and pass to pass: the test files the pull request changed.
set -e
sh /project/check.sh test/functional/persistence/many-to-many/persistence-many-to-many.test
