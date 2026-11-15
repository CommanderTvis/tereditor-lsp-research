#!/bin/sh
# Fail to pass: the type check of test/typings/describe.ts (Describe<true> and Describe<false>). Pass to pass: the rest of the type checks and the mocha suite, run by check.sh.
set -e
sh /project/check.sh
