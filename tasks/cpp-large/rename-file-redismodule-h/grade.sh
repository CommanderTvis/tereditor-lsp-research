#!/bin/sh
# Old path gone, new path present, deps/ unchanged, no C file, header or Makefile under src/, tests/modules/ or modules/
# names the old file; the example modules of src/modules build (their Makefile depends on the header by name); then
# the project's build (which compiles the module API test modules) and tests.
set -e
test ! -e src/redismodule.h
test -f src/redis_module_api.h
git diff --quiet HEAD -- deps
if grep -rn 'redismodule\.h' --include='*.c' --include='*.h' --include=Makefile src tests/modules modules; then exit 1; fi
make -C src/modules > /tmp/example-modules.log 2>&1 || { tail -30 /tmp/example-modules.log; exit 1; }
sh /project/check.sh
