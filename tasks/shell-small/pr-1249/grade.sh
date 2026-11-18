#!/bin/sh
# Mined pull request: the test files it changed (held-out, in place) are run by the work tree's bin/bats; every test in
# fail_to_pass.txt (fails at the base commit) and pass_to_pass.txt (passes before and after) must report "ok".
files='test/bats.bats'
out=/tmp/suite.tap
bin/bats --tap $files > $out 2>&1; cat $out
ok=$(sed -n 's/^ok [0-9][0-9]* //p' $out)
missing=$(cat "$TASK_DIR/fail_to_pass.txt" "$TASK_DIR/pass_to_pass.txt" | grep -v '^$' | while IFS= read -r t; do
  printf '%s\n' "$ok" | grep -Fxq -- "$t" || printf '%s\n' "$t"
done)
[ -z "$missing" ] || { echo "grade: not passing:"; echo "$missing"; exit 1; }
echo "grade: ok"
