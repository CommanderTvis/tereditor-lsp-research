#!/bin/sh
# Dependencies for grading, installed once per commit with network (vendor/ is git-ignored upstream and kept as the
# overlay). Upstream does not commit a lock file; each commit the study uses has one in locks/, named by the first 16
# hex digits of the sha256 of its composer.json, with the commit's release in <name>.version (the snapshot has no git
# tags, and composer needs the root package's version). The locks were resolved for PHP 8.4 (the grading toolchain)
# with `COMPOSER_ROOT_VERSION=<release> COMPOSER_NO_SECURITY_BLOCKING=1 composer update --no-install --ignore-platform-req=ext-*` (old commits need
# dependency versions that now have security advisories), so every reproduction installs the same versions.
set -e
h=$(sha256sum composer.json | cut -c1-16)
[ -f "/project/locks/$h.lock" ] || { echo "grade-setup.sh: no lock for composer.json $h" >&2; exit 1; }
cp "/project/locks/$h.lock" composer.lock
COMPOSER_ROOT_VERSION=$(cat "/project/locks/$h.version") COMPOSER_ALLOW_SUPERUSER=1 \
  composer install --no-interaction --no-progress --no-plugins --no-scripts
