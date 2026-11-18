#!/bin/sh
# The parameters are in the new order, every call passes the version first, then the project check.
set -e
grep -qE '^@mixin deprecate\(\$deprecate-version, \$name, \$remove-version, \$ignore-warning: false\)' core/scss/mixins/bootstrap/_deprecate.scss
[ "$(grep -rE '@mixin deprecate[[:space:]]*\(' core/scss | wc -l)" -eq 1 ]
calls=$(grep -rE '@include deprecate\(' core/scss | wc -l)
[ "$calls" -eq 3 ]
[ "$(grep -rE "@include deprecate\('v?[0-9]" core/scss | wc -l)" -eq 3 ]
sh /project/check.sh
