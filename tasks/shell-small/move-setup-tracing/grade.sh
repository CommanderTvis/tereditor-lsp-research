#!/bin/sh
# The function is defined in the new file only, the old file does not source the new one, then the full suite.
set -e
def='^[[:space:]]*(function[[:space:]]+)?bats_setup_tracing[[:space:]]*\(\)'
grep -qE "$def" lib/bats-core/setup_tracing.bash
[ "$(grep -rlE "$def" bin lib libexec | wc -l)" -eq 1 ]
! grep -q 'setup_tracing\.bash' lib/bats-core/tracing.bash
sh /project/check.sh
