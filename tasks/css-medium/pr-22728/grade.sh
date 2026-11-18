#!/bin/sh
# Mined pull request: the Jest test files it changed (held-out, in place) run with the repository's own Jest setup; every test in
# fail_to_pass.txt (fails at the base commit) and pass_to_pass.txt (passes before and after) must pass.
export HOME="${HOME:-/tmp}" BABEL_ENV=test
node_modules/.bin/jest --ci --json --outputFile=/tmp/jest.json packages/react/src/__tests__/index-test.js packages/utilities/src/date-picker/primitives/__tests__/calendar-grid-test.js packages/utilities/src/date-picker/primitives/__tests__/calendar-labels-test.js packages/utilities/src/date-picker/primitives/__tests__/click-outside-handler-test.js packages/utilities/src/date-picker/primitives/__tests__/machine-focus-restoration-test.js 2>&1 | tail -n 100
node /project/jest-check.js /tmp/jest.json "$TASK_DIR/fail_to_pass.txt" "$TASK_DIR/pass_to_pass.txt"
