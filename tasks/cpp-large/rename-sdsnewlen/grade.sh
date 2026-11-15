#!/bin/sh
# deps/ is unchanged; Redis's own sds no longer has the old name anywhere it is used (the only remaining mentions may be
# in the three programs that use hiredis's sds through sdscompat.h, where the name means hi_sdsnewlen); the new name is
# declared; then the project's build (which fails if a hiredis call site was renamed) and its C unit tests.
set -e
git diff --quiet HEAD -- deps
if grep -rnw sdsnewlen --include='*.c' --include='*.h' src tests/modules modules \
  | grep -v -e '^src/redis-cli\.c:' -e '^src/cli_common\.c:' -e '^src/redis-benchmark\.c:'; then exit 1; fi
grep -qw sdsnewbuf src/sds.h
sh /project/check.sh
