#!/bin/sh
# Derives the candidate pools and oracle.txt with clang -Wshadow (a compiler, not a language server), run from a
# checkout of the pinned commit: sh derive-oracle.sh <redis-checkout>. Every C file of the server (REDIS_SERVER_OBJ
# in src/Makefile, release.c excluded: generated at build time) is compiled with the build's include paths and
# defines; a file is a positive if clang reports "declaration shadows a local variable" at a location in that file
# that is not inside a macro expansion, a decoy if it reports none at all (files with only macro-produced reports are
# in neither pool). Then a seeded draw of 5 positives and 5 decoys.
set -e
cd "$1/src"
flags="-std=gnu11 -DREDIS_TEST -DINCLUDE_VEC_SETS=1 -I../deps/hiredis -I../deps/linenoise -I../deps/lua/src -I../deps/hdr_histogram -I../deps/fpconv -I../deps/xxhash"
srcs=$(sed -n 's/^REDIS_SERVER_OBJ=//p' Makefile | tr ' ' '\n' | sed 's/\.o$/.c/' | grep -v '^release.c$' | sort -u)
: > /tmp/shadow.txt; : > /tmp/all.txt
for f in $srcs; do
  [ -f "$f" ] || continue; echo "src/$f" >> /tmp/all.txt
  clang $flags -fsyntax-only -Wno-everything -Wshadow -fno-caret-diagnostics "$f" 2>&1 | awk -v f="$f" '
    /: warning: / { if (w) print w "\t" m; w = ""; m = "direct"
                    if (index($0, f ":") == 1 && $0 ~ /declaration shadows a local variable/) w = $0; next }
    /expanded from macro/ { if (w) m = "macro" }
    END { if (w) print w "\t" m }' | sed 's|^|src/|' >> /tmp/shadow.txt
done
awk -F'\t' '$2 == "direct" { split($1, a, ":"); print a[1] }' /tmp/shadow.txt | sort -u > /tmp/pos.txt
awk -F'\t' '{ split($1, a, ":"); print a[1] }' /tmp/shadow.txt | sort -u > /tmp/any.txt
sort /tmp/all.txt | comm -23 - /tmp/any.txt > /tmp/neg.txt
echo "positives $(wc -l < /tmp/pos.txt), decoys $(wc -l < /tmp/neg.txt), files $(wc -l < /tmp/all.txt)" >&2
pick() { awk 'BEGIN { srand(20261110) } { printf "%.12f\t%s\n", rand(), $0 }' "$1" | sort -k1,1n | head -5 | cut -f2; }
echo "decoys: $(pick /tmp/neg.txt | tr '\n' ' ')" >&2
pick /tmp/pos.txt | sort
