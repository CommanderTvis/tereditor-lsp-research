#!/bin/sh
# Fail to pass and pass to pass: src/middleware/cors/index.test.ts src/middleware/validator/validator.test.ts src/utils/url.test.ts (the test files the pull request changed; jest runs every case in them).
set -e
sh /project/check.sh src/middleware/cors/index.test.ts src/middleware/validator/validator.test.ts src/utils/url.test.ts
