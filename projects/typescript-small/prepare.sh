#!/bin/sh
# Installs node_modules (type declarations for the TypeScript server) with the managed Bun; no install scripts run.
# Upstream git-ignores node_modules/ and package-lock.json; Bun's own lockfile is excluded here.
set -eu
bun=$(ls /cache/managed/runtimes/bun/*/bun-linux-*/bun | head -n1)
BUN_INSTALL_CACHE_DIR=/tmp/bun-cache "$bun" install --ignore-scripts --no-progress
rm -rf /tmp/bun-cache
printf '%s\n' bun.lock bun.lockb >> .git/info/exclude
