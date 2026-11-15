#!/bin/sh
# guzzle#2916 at its base commit: a syntax check of the library, then the pull request's test file (its 2 new tests
# fail before the fix; the file's other tests pass before and after). The project's bootstrap starts guzzle's node.js
# test server, which the grading sandbox does not have: the autoloader replaces it, and the 3 tests of the file that
# send real requests to that server are excluded.
set -e
find src -name '*.php' -print0 | xargs -0 -n 50 sh -c 'for f; do php -l "$f" >/dev/null || exit 1; done' sh
php vendor/bin/phpunit --bootstrap vendor/autoload.php --order-by=default --no-coverage --do-not-cache-result \
  --filter '/^(?!.*::(testUsesDefaultHandler|testCanSendAsyncGetRequests|testAddsAcceptEncodingbyCurl)\b)/' \
  tests/ClientTest.php
