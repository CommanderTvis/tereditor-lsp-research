#!/bin/sh
# Fail to pass and pass to pass: the test files the pull request changed (end-to-end specs excluded: no browsers).
set -e
sh /project/check.sh test/queues/int.spec.ts test/queues/postgres-logs.int.spec.ts
