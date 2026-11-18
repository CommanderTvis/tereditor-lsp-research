#!/bin/sh
# Build-and-test for Redis, offline. The build: every program and the module API test modules (make all), with libc
# malloc (the vendored jemalloc needs autotools-era configure steps) and REDIS_TEST, which compiles the server's C unit
# tests in. The tests: those C unit tests, suite by suite (redis-server test <name> for every entry of the redisTests
# table in src/server.c: sds, dict, listpack, quicklist, ziplist, intset, rax, zset, kvstore, ...), except "util": its
# test_reclaimFilePageCache asserts on the kernel's page cache, which the grading sandbox's filesystem does not
# provide. The Tcl integration suite is run per task by grade.sh (tclsh).
set -e
make -j 3 MALLOC=libc BUILD_TLS=no OPTIMIZATION=-O1 REDIS_CFLAGS=-DREDIS_TEST > /tmp/make.log 2>&1 \
  || { grep -E -B2 -A4 'error|Error' /tmp/make.log | head -80; exit 1; }
suites=$(sed -n '/redisTests\[\] *=/,/};/p' src/server.c | sed -n 's/^[[:space:]]*{"\([a-z0-9_]*\)".*/\1/p' | grep -v '^util$')
[ -n "$suites" ] || { echo "no unit test suites found in src/server.c"; exit 1; }
for s in $suites; do
  ./src/redis-server test "$s" > /tmp/unit-$s.log 2>&1 || { tail -40 /tmp/unit-$s.log; echo "unit suite $s failed"; exit 1; }
done
echo "unit suites passed: $(echo $suites | wc -w)"
