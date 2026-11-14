#!/bin/sh
# In an Alpine container with git, jq and scc: shallow-fetch one commit, count code lines per language with scc (blank and comment lines excluded,
# vendored and third-party directories skipped), print one JSON line, delete the clone.
lang=$1 repo=$2 tag=$3 sha=$4
d=/work/$(echo "$repo" | tr / _)
rm -rf "$d" && mkdir -p "$d" && cd "$d" && git init -q && git remote add o "https://github.com/$repo" \
  && git fetch -q --depth 1 o "$sha" && git checkout -q FETCH_HEAD || { echo "{\"repo\":\"$repo\",\"error\":\"fetch\"}"; exit 0; }
/bin/scc --format json --no-cocomo --exclude-dir vendor,third_party,third-party,thirdparty,external,node_modules,.git . \
  | jq -c --arg lang "$lang" --arg repo "$repo" --arg tag "$tag" --arg sha "$sha" \
    '{lang:$lang, repo:$repo, tag:$tag, sha:$sha, code:(map({key:.Name, value:.Code}) | from_entries)}'
cd / && rm -rf "$d"
