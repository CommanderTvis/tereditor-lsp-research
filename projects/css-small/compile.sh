#!/bin/sh
# compile.sh <out-dir>: compile every top-level Sass entry point of core/scss (the files not starting with an underscore) with
# the repository's own sass into <out-dir>. A failing entry point leaves <name>.failed (no message).
out=$1; rm -rf "$out"; mkdir -p "$out"
for f in core/scss/*.scss; do
  case "$(basename "$f")" in _*) continue ;; esac
  n=$(basename "$f" .scss)
  core/node_modules/.bin/sass --no-source-map --style=expanded --quiet --quiet-deps --load-path=node_modules --load-path=core/node_modules "$f" "$out/$n.css" >/dev/null 2>&1 || echo failed > "$out/$n.failed"
done
echo "compile: $(ls "$out" | grep -c '\.css$') entry points, $(ls "$out" | grep -c '\.failed$') failed" >&2
