#!/bin/sh
# Dependencies for grading, resolved once per commit with network (node_modules/ is kept as the overlay).
# - pnpm-lock.yaml (the pinned commit): pnpm install from the lockfile.
# - yarn.lock (the 2022 base commits of the mined pull requests): pnpm imports the yarn v1 lockfile, so the same
#   versions are installed without Yarn, into a flat node_modules as Yarn would lay it out.
set -e
# The grading toolchain's pnpm is used as it is: a packageManager field naming another pnpm version would make it
# download that version's prebuilt binary, which cannot run here (no FHS loader in the sandbox).
export npm_config_manage_package_manager_versions=false npm_config_package_manager_strict=false
export pnpm_config_manage_package_manager_versions=false pnpm_config_package_manager_strict=false
export COREPACK_ENABLE_STRICT=0
if [ -f pnpm-lock.yaml ]; then
  pnpm install --frozen-lockfile --ignore-scripts --config.manage-package-manager-versions=false --config.package-manager-strict=false
elif [ -f yarn.lock ]; then
  pnpm import
  pnpm install --frozen-lockfile --ignore-scripts --config.node-linker=hoisted
elif [ -f bun.lock ] && command -v bun >/dev/null 2>&1; then
  bun install --frozen-lockfile --ignore-scripts --no-progress
else
  npm install --ignore-scripts --no-audit --no-fund --legacy-peer-deps
fi
