#!/bin/sh
# Build-and-test for dedoc/scramble, offline: a syntax check of every PHP file under src/ (PHP has no build step), then the
# Pest tests of the files or directories given as arguments (the modules a task affects; each task's grade.sh names them),
# in a fixed order. Without arguments: the whole suite.
set -e
find src -name '*.php' -print0 | xargs -0 -n 100 -P 4 sh -c 'for f; do php -l "$f" >/dev/null || exit 1; done' sh
[ $# -gt 0 ] || set -- tests
php -d memory_limit=2G vendor/bin/pest --order-by=default --do-not-cache-result --no-coverage "$@"
