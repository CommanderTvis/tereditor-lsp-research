#!/bin/sh
# Build-and-test for primer/css: compile every bundle (src/**/index.scss, as script/dist.js does) with dart-sass,
# then require the compiled CSS to be identical to that of the task's starting state (the snapshot with the grading
# overlay and the task's setup.patch), since every task on this project is a behaviour-preserving refactoring.
set -e
compile() { # <tree> <out-dir>
  rm -rf "$2"; mkdir -p "$2"
  (cd "$1" && find src -name index.scss | sort) | while IFS= read -r f; do
    o="$2/$(echo "${f#src/}" | tr / _).css"
    (cd "$1" && sass --no-source-map --style=expanded --quiet --load-path=node_modules "$f" "$o") || { echo "check: $f does not compile" >&2; exit 1; }
  done
}
ref=/tmp/check-ref; rm -rf "$ref"; cp -a /study/snapshot "$ref"
[ -d /grade-overlay ] && cp -a /grade-overlay/. "$ref/"
if [ -s "${TASK_DIR:-/task}/setup.patch" ]; then (cd "$ref" && git apply --whitespace=nowarn "${TASK_DIR:-/task}/setup.patch"); fi
compile "$ref" /tmp/check-out-ref
compile "$PWD" /tmp/check-out-work
# The set of bundles must stay the same, and each must compile to the same CSS.
diff -r /tmp/check-out-ref /tmp/check-out-work > /tmp/check.diff || { head -80 /tmp/check.diff; echo "check: compiled CSS differs" >&2; exit 1; }
echo "check: $(ls /tmp/check-out-work | wc -l) bundles compile to identical CSS"
