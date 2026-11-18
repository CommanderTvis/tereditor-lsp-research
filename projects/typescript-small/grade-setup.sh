#!/bin/sh
# Dependencies for grading, resolved once per commit with network (node_modules/ is kept as the overlay): pnpm install
# from upstream's pnpm-lock.yaml, no install scripts.
set -e
# The toolchain's pnpm is newer than the packageManager field names; do not try to download another version.
export npm_config_manage_package_manager_versions=false npm_config_package_manager_strict=false
export pnpm_config_manage_package_manager_versions=false pnpm_config_package_manager_strict=false
export pnpm_config_pm_on_fail=ignore npm_config_pm_on_fail=ignore COREPACK_ENABLE_STRICT=0
flags="--ignore-scripts --filter . --config.manage-package-manager-versions=false --config.package-manager-strict=false"
# One base commit's lockfile (with a file: importer for benchmarks/fetch) does not parse with the toolchain's pnpm:
# there, resolve from package.json ranges instead, without the benchmarks workspace (its file: link breaks pnpm).
pnpm install --frozen-lockfile $flags || { rm -f pnpm-lock.yaml pnpm-workspace.yaml benchmarks/fetch/package.json; pnpm install --no-frozen-lockfile $flags; }
