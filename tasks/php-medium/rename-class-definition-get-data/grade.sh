#!/bin/sh
# Renamed on the contract and both implementations, nothing calls the old name.
set -e
grep -q 'public function getDefinitionData(): ClassDefinitionData;' src/Infer/Contracts/ClassDefinition.php
! grep -rn 'getData(' src tests --include=*.php
sh /project/check.sh tests/StudyHiddenRenameTest.php tests/Infer
