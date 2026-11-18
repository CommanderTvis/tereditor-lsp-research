#!/bin/sh
# rename-file: the file has its new name and the old one is gone, no whole-word trace of the old name in the Kotlin sources and
# the Markdown docs, then the library modules compile and the hidden test (it names the new type) passes.
set -e
d=core/src/main/kotlin/org/jetbrains/kotlinx/dataframe/schema
test ! -e $d/DataFrameSchema.kt || { echo "old file still present"; exit 1; }
test -f $d/TypedFrameSchema.kt || { echo "new file missing"; exit 1; }
if grep -rIn -w --include=*.kt --include=*.md --exclude-dir=build --exclude-dir=.git --exclude-dir=.gradle --exclude-dir=generated-sources --exclude=AGENTS.md --exclude=CLAUDE.md DataFrameSchema . ; then echo "old name left"; exit 1; fi
sh /project/check.sh :core:test --tests 'org.jetbrains.kotlinx.dataframe.StudyHiddenRenameFileTest'
