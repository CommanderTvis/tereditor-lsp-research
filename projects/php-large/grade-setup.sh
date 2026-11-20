#!/bin/sh
# Dependencies for grading, installed once per commit with network (vendor/ is git-ignored upstream and kept as the
# overlay). Upstream does not commit a lock file; each commit the study uses has one in locks/, named by the first 16
# hex digits of the sha256 of its composer.json, with the commit's release in <name>.version (the snapshot has no git
# tags, and composer needs the root package's version). The locks were resolved for PHP 8.4 (the grading toolchain)
# with `COMPOSER_ROOT_VERSION=<release> COMPOSER_NO_SECURITY_BLOCKING=1 composer update --no-install --ignore-platform-req=ext-*` (old commits need
# dependency versions that now have security advisories), so every reproduction installs the same versions.
set -e
# A retry starts from the original composer.json, not from the one the fallback below edits.
[ -f composer.json.study-orig ] && cp composer.json.study-orig composer.json || cp composer.json composer.json.study-orig
h=$(sha256sum composer.json | cut -c1-16)
[ -f "/project/locks/$h.lock" ] || { echo "grade-setup.sh: no lock for composer.json $h" >&2; exit 1; }
cp "/project/locks/$h.lock" composer.lock
export COMPOSER_ROOT_VERSION=$(cat "/project/locks/$h.version") COMPOSER_ALLOW_SUPERUSER=1
composer install --no-interaction --no-progress --no-plugins --no-scripts && exit 0
# Where the GitHub API refuses anonymous zip downloads (no token, rate limit, per-repository policy), the same locked
# versions come from git clones instead; a clone that the network refuses once is retried (the clone cache is kept).
# phpstan/phpstan is dist-only (a phar from the GitHub API) and a static-analysis tool that no grader uses (and the dev packages that require it) is left
# out of this working copy's composer.json and lock (the overlay is vendor/ only).
cat > /tmp/study-drop.php <<'PHP'
<?php
// Leaves out phpstan/phpstan and every dev package that (transitively) requires it, from the lock and composer.json.
$l = json_decode(file_get_contents("composer.lock"), true);
$drop = ["phpstan/phpstan" => true];
do {
    $n = count($drop);
    foreach ($l["packages-dev"] as $p) {
        foreach (array_keys(($p["require"] ?? [])) as $r) { if (isset($drop[$r])) { $drop[$p["name"]] = true; } }
    }
} while (count($drop) > $n);
$l["packages-dev"] = array_values(array_filter($l["packages-dev"], fn ($p) => !isset($drop[$p["name"]])));
file_put_contents("composer.lock", json_encode($l, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT));
$j = json_decode(file_get_contents("composer.json"), true);
foreach (array_keys($drop) as $d) { unset($j["require-dev"][$d]); }
file_put_contents("composer.json", json_encode($j, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT));
PHP
php /tmp/study-drop.php
# Blobless clones, no composer cache: each package is cloned once and only the files of the locked commit are fetched
# (the full clones of a large project's dependencies would not fit the disk).
export COMPOSER_CACHE_DIR=/dev/null GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=clone.filter GIT_CONFIG_VALUE_0=blob:none
for i in 1 2 3 4 5 6; do
  composer install --no-interaction --no-progress --no-plugins --no-scripts --prefer-source && { find vendor -name .git -prune -exec rm -rf {} + || true; rm -rf "${COMPOSER_HOME:-$HOME/.composer}/cache" "$HOME/.cache/composer"; exit 0; }
  sleep 20
done
exit 1
