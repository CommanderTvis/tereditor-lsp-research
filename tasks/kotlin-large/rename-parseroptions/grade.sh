#!/bin/sh
# rename: no whole-word trace of the old name in the Kotlin sources and the Markdown docs (outside the regenerated copies and the dumps),
# the new name is declared, then the library modules compile and the hidden test (it names the new class) passes.
set -e
if grep -rIn -w --include=*.kt --include=*.md --exclude-dir=build --exclude-dir=.git --exclude-dir=.gradle --exclude-dir=generated-sources --exclude=AGENTS.md --exclude=CLAUDE.md ParserOptions . | grep -v 'DocumentationUrls\.ParserOptions' | grep -v 'typealias ParserOptions' | grep .; then echo "old name left"; exit 1; fi
grep -rIq --include=*.kt -w 'class ParsingConfig' core/src/main || { echo "ParsingConfig is not declared"; exit 1; }
sh /project/check.sh :core:test --tests 'org.jetbrains.kotlinx.dataframe.StudyHiddenRenameTest'
