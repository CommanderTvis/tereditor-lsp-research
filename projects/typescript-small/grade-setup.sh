#!/bin/sh
# Dependencies for grading, resolved once per commit with network (node_modules/ is kept as the overlay).
# - package-lock.json in the tree: npm ci.
# - yarn.lock (before the switch to npm): pnpm imports the yarn v1 lockfile, so the same versions are installed
#   without Yarn, into a flat node_modules as Yarn would lay it out.
# - neither (the pinned commit: upstream git-ignores package-lock.json): the lockfile recorded with this project.
set -e
if [ -f package-lock.json ]; then
  npm ci --ignore-scripts --no-audit --no-fund
elif [ -f yarn.lock ]; then
  pnpm import
  pnpm install --frozen-lockfile --ignore-scripts --config.node-linker=hoisted
else
  cp /project/package-lock.json package-lock.json
  npm ci --ignore-scripts --no-audit --no-fund
fi
