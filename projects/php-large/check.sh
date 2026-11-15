#!/bin/sh
# Build-and-test for laravel/framework: a syntax check of every PHP file under src/ (PHP has no build step), then the
# PHPUnit tests of the directories or files given as arguments (the modules a task affects; each task's grade.sh names
# them). The whole suite (16,000 tests) is not run: part of it needs services (Redis, MySQL, DynamoDB) and PHP
# extensions the grading sandbox does not have. Without arguments: the Support and Container tests.
set -e
find src -name '*.php' -print0 | xargs -0 -n 100 -P 4 sh -c 'for f; do php -l "$f" >/dev/null || exit 1; done' sh
[ $# -gt 0 ] || set -- tests/Container tests/Support
php -d memory_limit=2G vendor/bin/phpunit --no-coverage --do-not-cache-result "$@"
