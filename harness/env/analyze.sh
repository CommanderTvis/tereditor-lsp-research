# analyze.sh <plan>: extraction and the analysis with the environment's pinned Python packages.
set -eu
"$STUDY_ANALYSIS/bin/python3" "$STUDY_ROOT/analysis/extract.py" "$1"
"$STUDY_ANALYSIS/bin/python3" "$STUDY_ROOT/analysis/report.py" "$1"
[ -n "${STUDY_HOST_UID:-}" ] && chown -R "$STUDY_HOST_UID:${STUDY_HOST_GID:-$STUDY_HOST_UID}" "$STUDY_ROOT/results/$1" 2>/dev/null || true
