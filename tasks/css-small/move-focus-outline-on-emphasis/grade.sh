#!/bin/sh
# Defined in the new partial only, then every bundle compiles to the same CSS as before.
set -e
def='@mixin[[:space:]]+focusOutlineOnEmphasis[[:space:]]*\('
grep -qE "$def" src/support/mixins/focus-outline-on-emphasis.scss
[ "$(grep -rlE "$def" src | wc -l)" -eq 1 ]
sh /project/check.sh
