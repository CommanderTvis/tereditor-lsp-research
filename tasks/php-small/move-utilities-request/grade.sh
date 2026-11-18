#!/bin/sh
# Moved, not copied: the old file is gone, the class is declared in the root namespace, nothing refers to the old name.
set -e
test ! -e src/Utilities/Request.php
grep -q '^namespace Yajra\\DataTables;' src/Request.php
grep -q '^class Request\b' src/Request.php
! grep -rn 'Utilities\\Request' src tests
sh /project/check.sh
