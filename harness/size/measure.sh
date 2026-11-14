#!/bin/sh
# Re-measures project sizes: code lines per language (scc 3.5.0; blank and comment lines excluded; vendor/,
# third_party/, external/, node_modules/ skipped; tests included) at each pinned commit in candidates.tsv
# (language, repo, tag, sha). Needs only a container runtime. Output: one JSON line per project on stdout.
#   sh harness/size/measure.sh [candidates.tsv] > counts.jsonl
set -eu
here=$(cd "$(dirname "$0")" && pwd)
list=${1:-$here/candidates.tsv}
rt=${STUDY_RUNTIME:-$(command -v docker >/dev/null 2>&1 && echo docker || echo container)}
bin=$(mktemp -d)
$rt run --rm -v "$bin:/out" --entrypoint /bin/sh golang:1.25 \
  -c 'CGO_ENABLED=0 go install github.com/boyter/scc/v3@v3.5.0 && cp /go/bin/scc /out/' >&2
cp "$list" "$bin/list.tsv"; cp "$here/count.sh" "$bin/count.sh"
$rt run --rm -v "$bin:/s" --entrypoint /bin/sh alpine:3.22 -c \
  'apk add -q git jq && cp /s/scc /bin/scc && mkdir -p /work && while IFS="	" read -r l r t s; do sh /s/count.sh "$l" "$r" "$t" "$s"; done < /s/list.tsv'
rm -rf "$bin"
