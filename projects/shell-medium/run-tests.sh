#!/bin/sh
# run-tests.sh <test dir> ...: runs every executable test file directly in each directory the way urchin does (setup_dir, then
# for each test setup, the test with bash when it has no shebang or #!/bin/sh and otherwise itself, teardown, then
# teardown_dir), without descending into subdirectories, and prints "PASS <dir>/<test>" or "FAIL <dir>/<test>" per test.
export PATH="$PWD/node_modules/.bin:$PATH" TERM=dumb
for v in $(set | awk -F= '$1 ~ "^NVM_" {print $1}'); do unset "$v"; done
export NVM_DIR="$PWD" TEST_SHELL=bash
root=$PWD
for d in "$@"; do
  ( cd "$root/$d" || exit 0
    [ -f setup_dir ] && [ -x setup_dir ] && ./setup_dir >/dev/null 2>&1
    for t in *; do
      case "$t" in setup|teardown|setup_dir|teardown_dir) continue ;; esac
      [ -f "$t" ] && [ -x "$t" ] || continue
      [ -f setup ] && [ -x setup ] && ./setup >/dev/null 2>&1
      if head -n 1 "./$t" | grep -vqE '^#!' || head -n 1 "./$t" | grep -qE '^#![[:blank:]]*/bin/sh($|[[:blank:]])'; then
        bash "./$t" > /tmp/run-tests.out 2>&1
      else
        "./$t" > /tmp/run-tests.out 2>&1
      fi
      rc=$?
      [ -f teardown ] && [ -x teardown ] && ./teardown >/dev/null 2>&1
      if [ $rc -eq 0 ]; then echo "PASS $d/$t"; else echo "FAIL $d/$t"; sed 's/^/    /' /tmp/run-tests.out | head -20; fi
    done
    [ -f teardown_dir ] && [ -x teardown_dir ] && ./teardown_dir >/dev/null 2>&1
  )
done
