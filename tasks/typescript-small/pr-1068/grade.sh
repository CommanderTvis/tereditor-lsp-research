#!/bin/sh
# Fail to pass: test/api/validate.ts and the refine case invalid-multiple-refinements (refiners run when only nested refinements failed). Pass to pass: the rest of the type checks and the mocha suite, run by check.sh.
set -e
sh /project/check.sh
