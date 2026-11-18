#!/bin/sh
# The old name is gone from every file (only CHANGELOG.md, a historical record, may still name it), the new one is
# defined and used, and the project's build and tests pass.
set -e
if grep -rIn -w 'MD_FLAG_SUPERSCRIPTS' --exclude-dir=.git --exclude=CHANGELOG.md .; then exit 1; fi
grep -q '^#define MD_FLAG_SUPERSCRIPT_SPANS' src/md4c.h
grep -q 'MD_FLAG_SUPERSCRIPT_SPANS' md2html/md2html.c
sh /project/check.sh
