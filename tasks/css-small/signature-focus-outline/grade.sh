#!/bin/sh
# The parameters are in the new order, then every bundle compiles to the same CSS as before.
set -e
grep -qE '^@mixin focusOutline\([[:space:]]*\$outlineColor[[:space:]]*:.*,[[:space:]]*\$outlineOffset[[:space:]]*:[[:space:]]*-2px[[:space:]]*\)' src/support/mixins/misc.scss
[ "$(grep -rcE '@mixin focusOutline[[:space:]]*\(' src | awk -F: '{s+=$2} END {print s}')" -eq 1 ]
sh /project/check.sh
