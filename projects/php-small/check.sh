#!/bin/sh
# Build-and-test for league/container: a syntax check of every PHP file (PHP has no build step), then the test suite.
set -e
find src tests -name '*.php' -print0 | xargs -0 -n 50 -P 4 sh -c 'for f; do php -l "$f" >/dev/null || exit 1; done' sh
vendor/bin/phpunit --no-coverage --no-progress --do-not-cache-result
