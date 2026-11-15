#!/bin/sh
# Fail to pass and pass to pass: test/github-issues/4410 (FileLogger writes to the configured file path), on sql.js.
set -e
sh /project/check.sh test/github-issues/4410/issue-4410
