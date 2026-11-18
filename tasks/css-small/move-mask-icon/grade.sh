#!/bin/sh
# Defined in the new partial only, reachable through the forwarding chain, then the project check (identical CSS, SCSS tests).
set -e
def='@mixin[[:space:]]+mask-icon[[:space:]]*\('
grep -qE "$def" core/scss/mixins/_mask-icon.scss
[ "$(grep -rlE "$def" core/scss | wc -l)" -eq 1 ]
sh /project/check.sh
