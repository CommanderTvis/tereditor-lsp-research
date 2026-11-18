#!/bin/sh
# (runtest needs which(1), absent in the grader: tclsh runs the helper directly.)
# Fail to pass and pass to pass: build the server (libc malloc, no TLS, REDIS_TEST) and run the Tcl test units of the
# files the pull request changed (test_files in task.toml), with its versions of them (held out): tests/unit/X.tcl
# runs as unit/X, tests/integration/X.tcl as integration/X; changed test modules (tests/modules) are built first.
set -e
make -j 3 MALLOC=libc BUILD_TLS=no OPTIMIZATION=-O1 REDIS_CFLAGS=-DREDIS_TEST > /tmp/make.log 2>&1 \
  || { grep -E -B2 -A4 'error|Error' /tmp/make.log | head -80; exit 1; }
files=$(sed -n 's/^test_files = \[\(.*\)\]/\1/p' "${TASK_DIR:-/task}/task.toml" | tr -d '" ' | tr ',' '\n')
case "$files" in *tests/modules/*) make -C tests/modules > /tmp/modules.log 2>&1 || { tail -30 /tmp/modules.log; exit 1; } ;; esac
units=$(echo "$files" | sed -n 's|^tests/\(.*\)\.tcl$|\1|p')
[ -n "$units" ] || { echo "no Tcl test unit among: $files"; exit 1; }
args=""; for u in $units; do args="$args --single $u"; done
tclsh tests/test_helper.tcl $args --clients 1 --no-latency > /tmp/tests.log 2>&1 || { tail -60 /tmp/tests.log; exit 1; }
tail -n 4 /tmp/tests.log
grep -q 'All tests passed' /tmp/tests.log
