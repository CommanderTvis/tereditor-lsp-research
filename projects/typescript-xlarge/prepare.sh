#!/bin/sh
# Installs node_modules (type declarations for the TypeScript server) with the managed Bun; no install scripts run.
# Upstream git-ignores node_modules/ and uses pnpm: Bun migrates the pnpm lockfile, may write the workspace list into
# package.json files, and writes its own lockfile; the tracked package.json files are restored afterwards so the agent
# starts from a clean tree.
set -eu
find . -name package.json -not -path '*/node_modules/*' | tar -cf /tmp/package-json.tar -T -
bun=$(ls /cache/managed/runtimes/bun/*/bun-linux-*/bun | head -n1)
BUN_INSTALL_CACHE_DIR=/tmp/bun-cache "$bun" install --ignore-scripts --no-progress
rm -rf /tmp/bun-cache
tar -xf /tmp/package-json.tar
printf '%s\n' bun.lock bun.lockb >> .git/info/exclude
