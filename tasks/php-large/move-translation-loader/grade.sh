#!/bin/sh
# Moved, not copied: the old file is gone, the interface is declared one namespace up, nothing names the old one.
set -e
test ! -e src/Illuminate/Contracts/Translation/Loader.php
grep -q '^namespace Illuminate\\Contracts;' src/Illuminate/Contracts/Loader.php
grep -q '^interface Loader\b' src/Illuminate/Contracts/Loader.php
! grep -rn 'Contracts\\Translation\\Loader\b' src tests
sh /project/check.sh tests/Translation
