#!/bin/sh
# Run from a checkout of the pinned commit (needs cc). Prints the definition line of the function that runs at
# ctx->parser.enter_span: it marks every callback of src/md4c-html.c at run time and converts a document with emphasis.
set -e
d=$(mktemp -d); cp -R src md2html "$d"; cd "$d"
for f in enter_block leave_block enter_span leave_span text; do
  perl -0pi -e "s/(\\n$f\_callback\\([^)]*\\)\\n\\{)/\$1 fprintf(stderr, \"HIT $f\\\\n\");/" src/md4c-html.c
done
cc -I src -DMD_VERSION_MAJOR=0 -DMD_VERSION_MINOR=6 -DMD_VERSION_RELEASE=0 -o md2html-marked src/md4c.c src/md4c-html.c src/entity.c md2html/md2html.c md2html/cmdline.c
echo '*x*' | ./md2html-marked 2>&1 >/dev/null | sort | uniq -c
cd - >/dev/null; grep -n '^enter_span_callback' src/md4c-html.c | sed 's/^/src\/md4c-html.c:/;s/:\([0-9]*\):.*/:\1/' ; rm -rf "$d"
