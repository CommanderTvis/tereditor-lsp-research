#!/bin/sh
# Fail to pass: the mocha cases of test/validation/union/coercion.ts and coercion-nested.ts (union coercion with object/masked members). Pass to pass: the rest of the type checks and the mocha suite, run by check.sh.
set -e
sh /project/check.sh
