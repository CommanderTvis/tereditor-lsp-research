#!/bin/sh
# Build-and-test for nvm: its own urchin suites (test/fast, test/sourcing, test/install_script), run in bash by the work
# tree's nvm.sh (the Makefile's test-bash recipe without make). Every test must pass except the ones listed in
# check-known-failures.txt: tests of the unmodified project that fail in the grading sandbox (no network, no node, tools
# missing). Not run: test/slow, test/installation_node, test/installation_iojs (they download node) and test/xenial (a
# Dockerfile suite).
# urchin calls `which`, which the grading toolchain does not have
mkdir -p /tmp/study-shim; printf '#!/bin/sh\ncommand -v "$@"\n' > /tmp/study-shim/which; chmod +x /tmp/study-shim/which
export PATH="$PWD/node_modules/.bin:/tmp/study-shim:$PATH" TERM=dumb
for v in $(set | awk -F= '$1 ~ "^NVM_" {print $1}'); do unset "$v"; done
export NVM_DIR="$PWD"
: > /tmp/urchin-all.log
for suite in ${CHECK_SUITES:-fast sourcing install_script}; do
  echo "Running test suite: $suite"
  urchin -f -s bash "test/$suite" > "/tmp/urchin-$suite.log" 2>&1
  esc=$(printf '\033')
  sed "s/$esc\[[0-9;]*m//g" "/tmp/urchin-$suite.log" | grep -E '^ *(✓|✗) |tests? (passed|failed)' | tee -a /tmp/urchin-all.log
done
known=${KNOWN_FAILURES:-/project/check-known-failures.txt}
bad=$(grep -E '^ *✗ ' /tmp/urchin-all.log | sed -E 's/^ *✗ //' | sort -u | while IFS= read -r l; do grep -Fxq -- "$l" "$known" 2>/dev/null || echo "$l"; done)
[ -z "$bad" ] || { echo "check: failing tests:"; echo "$bad"; exit 1; }
[ "$(grep -c '^ *✓ ' /tmp/urchin-all.log)" -gt 100 ] || { echo "check: too few tests ran"; exit 1; }
echo "check: ok"
