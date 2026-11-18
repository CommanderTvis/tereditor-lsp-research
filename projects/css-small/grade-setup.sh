#!/bin/sh
# Grading dependencies, fetched once with network: pnpm (the version the repository pins in package.json, from the npm
# registry with the grading toolchain's npm), then the dependencies of @tabler/core from pnpm-lock.yaml without install scripts
# into node_modules/ and core/node_modules/ (git-ignored, so they become the grading overlay), and the reference
# compilation of the unmodified tree (compile.sh) in node_modules/.study-ref for check.sh.
set -e
ver=$(sed -n 's/.*"packageManager": "pnpm@\([0-9.]*\)".*/\1/p' package.json | head -n1)
[ -n "$ver" ]
npm install --prefix /tmp/study-pnpm --no-audit --no-fund "pnpm@$ver" >/dev/null
export PATH=/tmp/study-pnpm/node_modules/.bin:$PATH CI=1 npm_config_update_notifier=false
pnpm install --frozen-lockfile --ignore-scripts --filter "@tabler/core..."
sh /project/compile.sh /tmp/study-ref
rm -rf node_modules/.study-ref; mkdir -p node_modules/.study-ref; cp -a /tmp/study-ref/. node_modules/.study-ref/
