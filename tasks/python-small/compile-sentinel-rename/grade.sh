#!/bin/sh
# Build and tests pass, and no alias for the old name was added to toolz/utils.py.
set -e
! grep -nE '^\s*no_default\s*=' toolz/utils.py
sh /project/check.sh
