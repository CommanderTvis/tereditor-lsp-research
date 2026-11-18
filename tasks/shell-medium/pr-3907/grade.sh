#!/bin/sh
# Mined pull request: every test file of the directories its changed tests live in is run (urchin's way, project's run-tests.sh,
# the held-out versions in place); every test in fail_to_pass.txt (fails at the base commit) and pass_to_pass.txt (passes
# before and after) must pass.
sh /project/run-tests.sh 'test/fast/Unit tests' > /tmp/tests.out 2>&1
cat /tmp/tests.out | grep -E '^(PASS|FAIL) ' | tail -n 400
miss=$(cat "$TASK_DIR/fail_to_pass.txt" "$TASK_DIR/pass_to_pass.txt" | grep -v '^$' | while IFS= read -r l; do grep -Fxq -- "PASS $l" /tmp/tests.out || echo "$l"; done)
[ -z "$miss" ] || { echo "grade: not passing:"; echo "$miss"; exit 1; }
echo "grade: ok"
