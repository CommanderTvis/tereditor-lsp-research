#!/bin/sh
# Resolve the lockfile dependencies once for Sass compilation. JavaScript packages are deliberately not used by
# check.sh; they are present only where Carbon Sass imports a package-owned partial.
set -e
mkdir -p .study
npm ci --ignore-scripts --no-audit --no-fund --omit=optional
