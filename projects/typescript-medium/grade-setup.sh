#!/bin/sh
# Dependencies for grading, resolved once with network (node_modules/ is kept as the overlay).
set -e
pnpm install --frozen-lockfile --ignore-scripts
