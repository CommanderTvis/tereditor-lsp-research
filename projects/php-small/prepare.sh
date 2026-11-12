#!/bin/sh
# Intelephense resolves third-party types by indexing vendor/. There is no composer in the run image, so the packages
# the code base refers to are fetched here (image build time, network available) at the exact commits pinned in
# composer.lock, exported with `git archive` (which honours export-ignore, like a composer dist install).
# vendor/ is git-ignored upstream, so none of this is part of the agent's diff.
set -eu
while read -r name url ref; do
  [ -n "$name" ] || continue
  tmp=$(mktemp -d)
  git -C "$tmp" init -q && git -C "$tmp" fetch -q --depth 1 "$url" "$ref"
  mkdir -p "vendor/$name" && git -C "$tmp" archive FETCH_HEAD | tar -x -C "vendor/$name"
  rm -rf "$tmp"
done <<'LIST'
psr/container https://github.com/php-fig/container.git c71ecc56dfe541dbd90c5360474fbc405f8d5963
psr/event-dispatcher https://github.com/php-fig/event-dispatcher.git dbefd12671e8a14ec7f180cab83036ed26714bb0
phpunit/phpunit https://github.com/sebastianbergmann/phpunit.git 1d5a4a3c98fa1ca3a51402c74b66c2c8df85e0bb
LIST
git check-ignore -q vendor
