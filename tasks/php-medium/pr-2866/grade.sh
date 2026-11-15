#!/bin/sh
# guzzle#2866 at its base commit: a syntax check of the library, then the pull request's test file (its new data set
# fails before the fix; the file's other tests pass before and after). The test file needs no test server, so the
# project's own bootstrap (which starts one with node.js) is replaced by the autoloader.
set -e
find src -name '*.php' -print0 | xargs -0 -n 50 sh -c 'for f; do php -l "$f" >/dev/null || exit 1; done' sh
php vendor/bin/phpunit --bootstrap vendor/autoload.php --order-by=default --no-coverage --do-not-cache-result \
  tests/UtilsTest.php
