#!/bin/sh
# The old file is gone, the new file declares the interface, nothing refers to the old name.
set -e
test ! -e src/Infer/Extensions/ExpressionTypeInferExtension.php
grep -q '^interface ExpressionTypeInferenceExtension extends InferExtension' src/Infer/Extensions/ExpressionTypeInferenceExtension.php
! grep -rnw 'ExpressionTypeInferExtension' src tests --include=*.php
sh /project/check.sh tests/StudyHiddenRenameFileTest.php tests/Infer
