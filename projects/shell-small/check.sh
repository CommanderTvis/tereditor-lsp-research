#!/bin/sh
# Build-and-test for bats-core: its own test suite, run by the work tree's bin/bats (the patched code, not the bats of
# the grading toolchain), offline. Not run: test/timeout.bats, whose tests need ps or pkill, which the grading
# toolchain does not have (bats-exec-test refuses BATS_TEST_TIMEOUT without them).
set -e
bin/bats --tap $(ls test/*.bats | grep -v '^test/timeout\.bats$')
