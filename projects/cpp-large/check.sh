#!/bin/sh
# Build-and-test for Redis, offline. The build: every program and the module API test modules (make all), with libc
# malloc (the vendored jemalloc needs autotools-era configure steps) and REDIS_TEST, which compiles the server's C unit
# tests in. The tests: those C unit tests (redis-server test all: sds, dict, listpack, quicklist, ziplist, intset, rax,
# zset, kvstore, ...). The Tcl integration suite (./runtest) is not run: the grading toolchain has no tclsh.
set -e
make -j 4 MALLOC=libc BUILD_TLS=no OPTIMIZATION=-O1 REDIS_CFLAGS=-DREDIS_TEST > /tmp/make.log 2>&1 \
  || { grep -E -B2 -A4 'error|Error' /tmp/make.log | head -80; exit 1; }
./src/redis-server test all > /tmp/unit.log 2>&1 || { tail -60 /tmp/unit.log; exit 1; }
tail -n 2 /tmp/unit.log
grep -q ' 0 failed' /tmp/unit.log
