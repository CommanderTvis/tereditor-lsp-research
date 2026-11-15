#!/bin/sh
# Moved, not copied: the old file is gone, the class is declared in the root namespace, nothing refers to the old name.
set -e
test ! -e src/Exception/ContainerException.php
grep -q '^namespace League\\Container;' src/ContainerException.php
grep -q '^class ContainerException\b' src/ContainerException.php
! grep -rn 'Exception\\ContainerException' src tests
sh /project/check.sh
