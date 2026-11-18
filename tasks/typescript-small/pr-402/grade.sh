#!/bin/sh
# Fail to pass and pass to pass: the test files the pull request changed.
set -e
sh /project/check.sh test/content-length.test.ts test/request.test.ts test/server.test.ts
