#!/bin/sh
# Tests of payload at the commit being graded: vitest under Node 24 on sqlite (libsql) only, no browsers. Arguments are
# test files (a task's grade.sh passes the affected ones): *int.spec.ts run in the int project, other specs in the unit
# project. Without arguments: the unit tests of packages/payload.
set -e
export PATH="$(study-node24)/bin:$PATH"
export PAYLOAD_DATABASE=sqlite NODE_OPTIONS="--max-old-space-size=6144"
v=node_modules/vitest/vitest.mjs
[ $# -gt 0 ] || set -- packages/payload
int=""; unit=""
for f in "$@"; do case "$f" in *int.spec.ts) int="$int $f" ;; *) unit="$unit $f" ;; esac; done
[ -z "$unit" ] || node $v run --project unit $unit
[ -z "$int" ] || node $v run --project int $int
