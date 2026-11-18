#!/bin/sh
# Fail to pass and pass to pass: the test files the pull request changed.
set -e
sh /project/check.sh src/hono.test.ts src/router/common.case.test.ts src/router/pattern-router/router.test.ts src/router/trie-router/node.test.ts
