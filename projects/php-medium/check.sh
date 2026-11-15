#!/bin/sh
# Build-and-test for guzzle, offline: a syntax check of every PHP file (PHP has no build step), then the test suite.
# The grading sandbox has no node.js for guzzle's test server: /project/offline-bootstrap.php stands in for it, and a
# test that needs it is skipped (about 600 of 3,300). The tests excluded by name fail without network or without the
# server in ways the stand-in cannot skip (php-http's integration suite, and garbage/invalid-status server responses).
# Tests run in a fixed order (the configuration asks for a random one).
set -e
find src tests -name '*.php' -print0 | xargs -0 -n 50 -P 4 sh -c 'for f; do php -l "$f" >/dev/null || exit 1; done' sh
exclude='HttplugIntegrationTest::|PoolTest::testPoolHandlesInvalidResponseStatusAsResponseLessRejection|StreamHandlerTest::testHandlesInvalidStatusCodeGracefully|StreamHandlerTest::testClassifiesCollapsedHttpsProxyFailureByMessageFallback|CurlFactoryTest::testHandlesInvalidStatusCodeGracefully|CurlFactoryTest::testHandlesGarbageHttpServerGracefully'
php -d memory_limit=2G vendor/bin/phpunit --bootstrap /project/offline-bootstrap.php --order-by=default --no-coverage \
  --do-not-cache-result --filter "/^(?!.*($exclude))/" "$@"
