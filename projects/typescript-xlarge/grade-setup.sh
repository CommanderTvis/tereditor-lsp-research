#!/bin/sh
# Dependencies for grading, resolved once per commit with network (node_modules/ of every workspace package is kept as
# the overlay): pnpm install from upstream's pnpm-lock.yaml, no install scripts (native packages ship prebuilt binaries
# as optional dependencies; mongodb-memory-server's binary is never needed because tests run on sqlite only).
set -e
export PATH="$(study-node24)/bin:$PATH"
export npm_config_manage_package_manager_versions=false npm_config_package_manager_strict=false
export pnpm_config_manage_package_manager_versions=false pnpm_config_package_manager_strict=false
export pnpm_config_pm_on_fail=ignore npm_config_pm_on_fail=ignore COREPACK_ENABLE_STRICT=0
pnpm install --frozen-lockfile --ignore-scripts --config.manage-package-manager-versions=false --config.package-manager-strict=false
# The int tests load sharp@0.32.6 (not the optional-prebuilt 0.3x line): its install script downloads the native binary.
pnpm rebuild sharp
