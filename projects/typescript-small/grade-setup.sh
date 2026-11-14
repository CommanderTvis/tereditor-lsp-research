#!/bin/sh
# Dependencies for grading, resolved once with network (node_modules/ is kept as the overlay).
set -e
npm ci --ignore-scripts --no-audit --no-fund
