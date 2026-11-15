#!/bin/sh
# Compile the package-level Sass entrypoints. This is the meaningful offline check for the CSS-only contestant.
set -e
out=.study/css-out
rm -rf "$out"
mkdir -p "$out"
count=0
find packages -path '*/scss/index.scss' -type f | sort | while IFS= read -r f; do
  name=$(printf '%s' "${f#packages/}" | tr '/' '_')
  sass --no-source-map --style=expanded --quiet --load-path=node_modules "$f" "$out/$name.css"
  count=$((count + 1))
done
test "$(find "$out" -type f -name '*.css' | wc -l | tr -d ' ')" -gt 0
echo "check: Sass entrypoints compile"
