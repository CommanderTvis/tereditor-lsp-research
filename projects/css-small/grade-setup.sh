#!/bin/sh
# Grading dependencies, fetched once with network: @primer/primitives (the CSS custom properties that
# src/primitives and src/color-modes import) at the version package-lock.json pins, into node_modules/ (git-ignored,
# so it becomes the grading overlay). Nothing else of the npm tree is needed: grading compiles with dart-sass.
set -e
v=$(sed -n '/"node_modules\/@primer\/primitives": {/,/}/s/.*"version": "\([^"]*\)".*/\1/p' package-lock.json | head -n1)
[ -n "$v" ]
work=$PWD; tmp=$(mktemp -d)
(cd "$tmp" && npm install --no-audit --no-fund --ignore-scripts --no-package-lock "@primer/primitives@$v")
rm -rf "$work/node_modules"; cp -a "$tmp/node_modules" "$work/node_modules"; rm -rf "$tmp"
