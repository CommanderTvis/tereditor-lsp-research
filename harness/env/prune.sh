# prune.sh <project>: drop a finished project's snapshot, grading dependencies and run scratch, and unused Nix paths.
set -eu
rm -rf "$STUDY_STATE/projects/$1" "$STUDY_STATE/validate/$1" "$STUDY_STATE"/runs/*/"$1"-* 2>/dev/null || true
nix-collect-garbage >/dev/null 2>&1 || true
echo "[env] pruned $1; free: $(df -h "$STUDY_STATE" | awk 'NR==2 {print $4}')" >&2
