#!/bin/sh
# Dependencies for grading, resolved once with network (vendor/ is kept as the overlay). Every task of this project
# starts from the pinned commit, so the dependency versions are the ones locked in composer.lock (upstream ignores its
# lock file; this one was resolved for PHP 8.4 at the pin).
set -e
cp /project/composer.lock composer.lock
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-interaction --no-progress --no-plugins --no-scripts
