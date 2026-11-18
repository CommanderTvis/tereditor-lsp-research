#!/bin/sh
# The mixin is defined once under the new name and the old name is gone from every include; the partial, the module
# paths and the CSS class are untouched; every include was renamed (12); then every entry point still compiles to the same CSS.
set -e
def=packages/styles/scss/utilities/_visually-hidden.scss
g() { grep -r --include='*.scss' --exclude-dir=node_modules --exclude-dir=.nx "$@" packages; }
grep -qE '^@mixin screen-reader-only[[:space:]]*\{' "$def"
[ "$(g -lE '@mixin[[:space:]]+(visually-hidden|screen-reader-only)([^a-zA-Z0-9_-]|$)' | wc -l)" -eq 1 ]
! g -nE '@include[[:space:]]+([a-z-]+\.)?visually-hidden([^.a-zA-Z0-9_-]|$)|@include[[:space:]]+visually-hidden\.visually-hidden'
[ "$(g -hE '@include[[:space:]]+([a-z-]+\.)?screen-reader-only([^a-zA-Z0-9_-]|$)' | wc -l)" -eq 12 ]
[ "$(g -hE "visually-hidden'" | wc -l)" -eq 24 ]
[ "$(g -hE '\-\-visually-hidden' | wc -l)" -eq 13 ]
grep -qE "^@forward 'visually-hidden';" packages/styles/scss/utilities/_index.scss
sh /project/check.sh
