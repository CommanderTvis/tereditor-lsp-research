#!/bin/sh
# Old path gone, new path present, no file of the tree still names the old header (the library target md4c-html and
# src/md4c-html.c keep their names; only the header's file name is matched), then the project's build and tests.
set -e
test ! -e src/md4c-html.h
test -f src/md4c-render.h
if grep -rIn 'md4c-html\.h' --exclude-dir=.git .; then exit 1; fi
test -f src/md4c-html.c
sh /project/check.sh
