#!/bin/sh
# The script is at the new path only, no file refers to the old path (the method name script-nvm-exec and the 'nvm-exec:' message
# prefix may stay), it is still executable, the installer still knows the method, then the project check.
set -e
[ ! -e nvm-exec ] && [ -x nvm-runner ]
! grep -rInE '(^|[^[:alnum:]_-])nvm-exec([^[:alnum:]_:-]|$)' --exclude-dir=.git --exclude-dir=node_modules .
grep -q 'script-nvm-exec' install.sh
grep -q 'nvm-runner' install.sh
grep -q 'nvm-runner' nvm.sh
sh /project/check.sh
