#!/bin/sh
# mine-prs.sh <project> [max-candidates]: candidate pull requests for the project's mined tasks (docs/TASKS.md,
# "Mined pull requests"), selected as SWE-bench selects them, before any build. Reads GitHub through `gh` (any account;
# read-only) and writes tasks/<project>/pr-candidates.jsonl in a seeded random order, so the first candidates that
# validate become the tasks and nobody chooses among them.
#
# Kept: opened on or after 2026-07-01 and merged (after the June 2026 training-data cutoff of every model of the study,
# so neither the fix nor its drafts can be remembered; docs/MEMORIZATION.md) into the default branch; author not a bot; at least one linked issue it closes;
# changes at least one test file and at least one non-test source file of the project's language; at most 15 non-test
# source files. Each line: number, merged_at, base_sha (the pull request's base commit), merge_sha, issue title and
# body, test and source files.
set -eu
proj=$1 max=${2:-40}
root=$(cd "$(dirname "$0")/../.." && pwd)
pd=$root/projects/$proj
repo=$(sed -n 's/^repo = "https:\/\/github.com\/\(.*\)"$/\1/p' "$pd/project.toml")
[ -n "$repo" ] || { echo "mine-prs: no GitHub repo in $pd/project.toml" >&2; exit 2; }
case "${proj%-*}" in
  python) src='\.py$' ;; typescript) src='\.(ts|tsx|mts|cts|js|jsx|mjs|cjs)$' ;; csharp) src='\.cs$' ;; php) src='\.php$' ;;
  cpp) src='\.(c|h|cc|cpp|cxx|hh|hpp|hxx)$' ;; kotlin) src='\.kts?$' ;; java) src='\.java$' ;; java-kotlin) src='\.(java|kts?)$' ;;
  shell) src='\.(sh|bash)$|^[^.]+$' ;; css) src='\.(scss|sass|less|css)$' ;; *) echo "mine-prs: unknown language" >&2; exit 2 ;;
esac
test_re='(^|/)(tests?|spec|specs|__tests__|testing|test-data|testdata)/|(^|/)test_[^/]*$|_test\.[a-z]+$|Tests?\.[a-z]+$|\.test\.[a-z]+$|\.spec\.[a-z]+$|Spec\.[a-z]+$'
out=$root/tasks/$proj/pr-candidates.jsonl; mkdir -p "$(dirname "$out")"
tmp=$(mktemp)

# Merged pull requests after the cutoff that close at least one issue (GraphQL search, newest first, 100 per page).
cursor=""
for page in 1 2 3 4 5 6 7 8 9 10; do
  q="repo:$repo is:pr is:merged created:>=2026-07-01"
  gh api graphql -f q="$q" ${cursor:+-f after="$cursor"} -f query='
    query($q: String!, $after: String) {
      search(query: $q, type: ISSUE, first: 100, after: $after) {
        pageInfo { hasNextPage endCursor }
        nodes { ... on PullRequest {
          number mergedAt author { __typename login } baseRefName
          closingIssuesReferences(first: 3) { nodes { number title body } }
          files(first: 100) { nodes { path } }
          mergeCommit { oid }
        } }
      }
    }' > "$tmp.page"
  jq -c '.data.search.nodes[]' "$tmp.page" >> "$tmp"
  [ "$(jq -r '.data.search.pageInfo.hasNextPage' "$tmp.page")" = true ] || break
  cursor=$(jq -r '.data.search.pageInfo.endCursor' "$tmp.page")
done

default=$(gh api "repos/$repo" -q .default_branch)
jq -c --arg src "$src" --arg test "$test_re" --arg def "$default" '
  select(.author.__typename != "Bot" and (.author.login // "" | test("\\[bot\\]$|^dependabot|^renovate") | not))
  | select(.baseRefName == $def)
  | select((.closingIssuesReferences.nodes | length) > 0)
  | ([.files.nodes[].path]) as $f
  | ($f | map(select(test($test)))) as $tests
  | ($f | map(select(test($test) | not) | select(test($src)))) as $srcs
  | select(($tests | length) > 0 and ($srcs | length) > 0 and ($srcs | length) <= 15)
  | {number, merged_at: .mergedAt, merge_sha: .mergeCommit.oid,
     issue: (.closingIssuesReferences.nodes[0] | {number, title, body}), tests: $tests, sources: $srcs}' "$tmp" > "$tmp.kept"

# The pull request's base commit (REST base.sha, as SWE-bench uses), then a seeded shuffle.
: > "$tmp.full"
while IFS= read -r line; do
  n=$(printf '%s' "$line" | jq -r .number)
  base=$(gh api "repos/$repo/pulls/$n" -q .base.sha 2>/dev/null) || continue
  printf '%s' "$line" | jq -c --arg b "$base" '. + {base_sha: $b}' >> "$tmp.full"
done < "$tmp.kept"
awk -v seed=20261110 'BEGIN{srand(seed)} {printf "%.12f\t%s\n", rand(), $0}' "$tmp.full" | sort -k1,1n | cut -f2- \
  | head -n "$max" > "$out"
echo "mine-prs: $(wc -l < "$tmp.kept" | tr -d ' ') pull requests qualify; $(wc -l < "$out" | tr -d ' ') candidates in $out" >&2
rm -f "$tmp" "$tmp.page" "$tmp.kept" "$tmp.full"
