#!/bin/sh
# signature: the interface declares the new parameter order (the hidden test also calls it that way), the old order is gone, and the
# build and tests pass.
set -e
f=embabel-agent-api/src/main/kotlin/com/embabel/plan/Planner.kt
tr -d '\n ' < $f | grep -Eq 'funplanToGoal\(goal:Goal,actions:Collection<Action>,?\)' || { echo "new signature missing in $f"; exit 1; }
if tr -d '\n ' < $f | grep -Eq 'funplanToGoal\(actions:Collection<Action>,goal:Goal,?\)'; then echo "old signature left in $f"; exit 1; fi
TEST_FILTER='StudyHiddenSignatureTest' sh /project/check.sh
sh /project/check.sh
