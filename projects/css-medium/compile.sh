#!/bin/sh
# compile.sh <out-dir>: compile every Sass entry point of the work tree with dart-sass into <out-dir>: the package index
# files (packages/*/index.scss) and the web components' component stylesheets. An entry point that fails leaves
# <name>.failed (no message, so renamed paths in messages cannot differ), so a comparison fails on newly broken
# entry points only.
out=$1; rm -rf "$out"; mkdir -p "$out"
{ find packages -maxdepth 2 -name index.scss -not -path '*/node_modules/*'
  find packages/web-components/src -name '*.scss' -not -name '_*' -not -path '*/node_modules/*'; } | sort > "$out/.entries"
export out
xargs -P 3 -n 1 sh -c 'f=$1; n=$(printf "%s" "$f" | tr / _); sass --no-source-map --style=expanded --quiet --quiet-deps --load-path=node_modules "$f" "$out/$n.css" >/dev/null 2>&1 || echo failed > "$out/$n.failed"' sh < "$out/.entries"
echo "compile: $(wc -l < "$out/.entries" | tr -d ' ') entry points, $(ls "$out" | grep -c '\.failed$' || true) failed" >&2
