#!/bin/sh
# The old name is gone from every tracked file, the new one is defined once and used, other nvm_resolve_* functions untouched,
# then the project check.
set -e
! grep -rInE '(^|[^[:alnum:]_$-])nvm_resolve_alias([^[:alnum:]_-]|$)' --exclude-dir=.git --exclude-dir=node_modules .
[ "$(grep -cE '^nvm_follow_alias\(\)' nvm.sh)" -eq 1 ]
[ "$(grep -rIE '(^|[^[:alnum:]_$-])nvm_follow_alias([^[:alnum:]_-]|$)' --exclude-dir=.git --exclude-dir=node_modules . | wc -l)" -ge 50 ]
grep -qE '^nvm_resolve_local_alias\(\)' nvm.sh
sh /project/check.sh
