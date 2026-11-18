#!/bin/sh
# Derives the candidate pools and oracle.txt with clang -Wshadow (a compiler, not a language server), run from a
# checkout of the pinned commit configured with cmake -DDISABLE_UNITY=1 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON:
#   sh derive-oracle.sh <compile_commands.json>
# Pool: every .cpp under src/ that is in the compilation database. A file is a positive if clang reports "declaration
# shadows a local variable" at a location in that file that is not inside a macro expansion, a decoy if it reports
# nothing at all (files with only macro-produced reports are in neither pool). Then a seeded draw of 5 positives and
# 5 decoys.
set -e
cc=$1; out=${TMPDIR:-/tmp}/shadow.$$; mkdir -p "$out"; export cc PWD
jq -r --arg d "$PWD/src/" '.[] | select(.file | startswith($d)) | .file' "$cc" | sed "s|^$PWD/||" | sort > "$out/all.txt"
cat > "$out/one.sh" <<'EOS'
f=$1
cmd=$(jq -r --arg f "$PWD/$f" '.[] | select(.file == $f) | .command' "$cc" | sed -E 's/ -o [^ ]+//')
eval "$cmd -fsyntax-only -Wno-everything -Wshadow -fno-caret-diagnostics" 2>&1 | awk -v f="$PWD/$f" '
  /: warning: / { if (w) print w "\t" m; w = ""; m = "direct"
                  if (index($0, f ":") == 1 && $0 ~ /declaration shadows a local variable/) w = $0; next }
  /expanded from macro/ { if (w) m = "macro" }
  END { if (w) print w "\t" m }' | sed "s|^$PWD/||"
EOS
xargs -P 6 -n 1 sh "$out/one.sh" < "$out/all.txt" > "$out/shadow.txt"
awk -F'\t' '$2 == "direct" { split($1, a, ":"); print a[1] }' "$out/shadow.txt" | sort -u > "$out/pos.txt"
awk -F'\t' '{ split($1, a, ":"); print a[1] }' "$out/shadow.txt" | sort -u > "$out/any.txt"
comm -23 "$out/all.txt" "$out/any.txt" > "$out/neg.txt"
echo "positives $(wc -l < "$out/pos.txt"), decoys $(wc -l < "$out/neg.txt"), files $(wc -l < "$out/all.txt")" >&2
pick() { awk 'BEGIN { srand(20261110) } { printf "%.12f\t%s\n", rand(), $0 }' "$1" | sort -k1,1n | head -5 | cut -f2; }
echo "decoys: $(pick "$out/neg.txt" | tr '\n' ' ')" >&2
pick "$out/pos.txt" | sort
cp "$out/shadow.txt" ./shadow-reports.txt
