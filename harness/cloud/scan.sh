#!/bin/bash
# scan.sh <runs-dir> [run-id ...]: how many runs, and how many judge reviews, in a directory of run directories (an
# unpacked archive, or results/<plan>/runs) stopped on a usage limit and so are not results (docs/ANALYSIS_PLAN.md).
# A run counts when its stream.jsonl or stream-review.jsonl contains usage_limit_reached or matches limit_stop of
# harness/env/lib.sh (taken from there, so both stay one definition); a review counts when review/stream.jsonl does and
# the run itself did not. Without jq only the usage_limit_reached text is checked (a warning says so).
# Prints: runs=N limit_runs=A limit_reviews=B, and exits 1 if A or B is not 0. SCAN_LIST=1 also lists the run ids.
set -u
d=$1; shift
lib=$(cd "$(dirname "$0")/../env" && pwd)/lib.sh
eval "$(sed -n '/^limit_re=/,/^}/p' "$lib")"
declare -F limit_stop >/dev/null || { echo "scan.sh: no limit_stop in $lib" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "scan.sh: no jq, checking only for usage_limit_reached" >&2; limit_stop() { return 1; }; }
stopped() { local f; for f in "$@"; do [ -s "$f" ] && grep -q usage_limit_reached "$f" && return 0; done; limit_stop "$@"; }
# shellcheck disable=SC2046  # run ids have no spaces
[ $# -gt 0 ] || set -- $(cd "$d" && for r in */; do [ -d "$r" ] && echo "${r%/}"; done)
n=0 ag=0 rv=0
for r in "$@"; do
  [ -d "$d/$r" ] || continue; n=$((n+1))
  if stopped "$d/$r/stream.jsonl" "$d/$r/stream-review.jsonl"; then ag=$((ag+1)); [ "${SCAN_LIST:-}" = 1 ] && echo "limit run $r" >&2
  elif stopped "$d/$r/review/stream.jsonl"; then rv=$((rv+1)); [ "${SCAN_LIST:-}" = 1 ] && echo "limit review $r" >&2; fi
done
echo "runs=$n limit_runs=$ag limit_reviews=$rv"
[ "$ag" = 0 ] && [ "$rv" = 0 ]
