#!/bin/sh
# Build-and-test for node-server at the commit being graded: type-check sources and tests, then vitest (the whole Node
# suite, or only the test files given as arguments; a task's grade.sh passes the affected tests).
set -e
npx tsc --noEmit
# The suite has one test that binds the IPv6 loopback ("should serve on ipv6"); on a kernel without IPv6 (the Claude Code
# cloud VM) it cannot pass, with or without a task's change, so it is left out there and only there.
if [ -e /proc/net/if_inet6 ]; then
  npx vitest run "$@"
else
  npx vitest run "$@" -t '^(?!.*should serve on ipv6)'
fi
