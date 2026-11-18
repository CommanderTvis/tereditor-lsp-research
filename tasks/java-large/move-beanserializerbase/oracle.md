# Oracle: move BeanSerializerBase

No navigation answer. Grading is the build and the tests (check.sh) with a hidden test in the new package, plus checks that the old file and the old qualified name are gone (grade.sh). The reference solution (gold.patch) is a scripted move proven by `./study validate` (build and tests pass); no language server is involved.
