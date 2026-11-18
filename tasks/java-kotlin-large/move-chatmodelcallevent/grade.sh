#!/bin/sh
# move: ChatModelCallEvent is declared in com.embabel.agent.spi.support only, nothing refers to the old qualified name, and the
# build and tests (with the hidden test, which loads the new class and not the old) pass.
set -e
d=embabel-agent-api/src/main/kotlin/com/embabel/agent/spi/support
[ -f $d/ChatModelCallEvent.kt ] || { echo "missing $d/ChatModelCallEvent.kt"; exit 1; }
grep -q '^package com\.embabel\.agent\.spi\.support\s*$' $d/ChatModelCallEvent.kt || { echo "wrong package declaration"; exit 1; }
[ ! -e $d/springai/ChatModelCallEvent.kt ] || { echo "old file still present"; exit 1; }
left=$(grep -rIl 'spi\.support\.springai\.ChatModelCallEvent\|spi\.support\.springai\.chatModelCallEvent' --exclude-dir=target --exclude-dir=.git . | head -n5)
[ -z "$left" ] || { echo "old qualified name left in: $left"; exit 1; }
TEST_FILTER='StudyHiddenMoveTest' sh /project/check.sh
sh /project/check.sh
