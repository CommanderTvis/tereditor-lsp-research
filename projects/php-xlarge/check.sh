#!/bin/sh
# Build-and-test for shopware/shopware, offline: a syntax check of every PHP file under src/ (PHP has no build step), then the
# PHPUnit tests of the files or directories given as arguments (the modules a task affects; each task's grade.sh names them).
# Only the unit tests (tests/unit) are used: the integration tests need MySQL. Without arguments: the unit tests of the
# Framework Routing directory.
set -e
find src -name '*.php' -print0 | xargs -0 -n 200 -P 3 sh -c 'for f; do php -l "$f" >/dev/null || exit 1; done' sh
[ $# -gt 0 ] || set -- tests/unit/Core/Framework/Routing
export APP_ENV=test DATABASE_URL=mysql://root:root@127.0.0.1:3306/shopware
php -d memory_limit=3G vendor/bin/phpunit --bootstrap /project/unit-bootstrap.php --order-by=default --no-coverage --do-not-cache-result "$@"
