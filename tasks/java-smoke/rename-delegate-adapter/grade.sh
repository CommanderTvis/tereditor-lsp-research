#!/bin/sh
# No trace of the old name in the gson module's Java code, then the module builds and its tests (with the hidden one) pass.
set -e
! grep -rn --include=*.java '\bgetDelegateAdapter\b' gson
sh /project/check.sh
