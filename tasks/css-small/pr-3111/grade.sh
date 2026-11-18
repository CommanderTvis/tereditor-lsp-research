#!/bin/sh
# Mined pull request: the SCSS test files it changed (held-out, in place) run with the repository's vitest SCSS configuration;
# every test in fail_to_pass.txt (fails at the base commit) and pass_to_pass.txt (passes before and after) must pass.
export HOME="${HOME:-/tmp}" CI=1
(cd core && node_modules/.bin/vitest run --config vitest.scss.config.mjs --reporter=json --outputFile=/tmp/vitest.json scss/tests/input-group-flat.test.mjs 2>&1 | tail -n 40)
node /project/vitest-check.js /tmp/vitest.json "$TASK_DIR/fail_to_pass.txt" "$TASK_DIR/pass_to_pass.txt"
