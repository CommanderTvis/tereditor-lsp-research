#!/bin/sh
# dedoc/scramble#1278 at its base commit: the library's syntax check, then the pull request's test file(s) (its new tests fail before
# the fix; the other tests of the file(s) pass before and after).
set -e
exec sh /project/check.sh tests/Infer/AnnotatedReturnTypesTest.php tests/Infer/Services/ReferenceTypeResolverTest.php tests/InferExtensions/ModelExtensionTest.php
