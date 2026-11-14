#!/bin/sh
# Dependencies for grading, resolved once with network (vendor/ is kept as the overlay).
set -e
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-interaction --no-progress --no-plugins --no-scripts
