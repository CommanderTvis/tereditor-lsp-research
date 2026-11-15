#!/bin/sh
# Fail to pass and pass to pass: src/middleware/basic-auth/index.test.ts src/middleware/bearer-auth/index.test.ts (the test files the pull request changed; jest runs every case in them).
set -e
sh /project/check.sh src/middleware/basic-auth/index.test.ts src/middleware/bearer-auth/index.test.ts
