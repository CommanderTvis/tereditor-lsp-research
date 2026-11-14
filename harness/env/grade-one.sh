# grade-one.sh <plan> <run-id>: grade a finished run (results/<plan>/runs/<run-id>/grade/).
set -eu
plan=$1 rid=$2; P=$STUDY_ROOT/results/$plan; out=$P/runs/$rid
[ -f "$out/exit.json" ] || exit 0
[ -f "$out/grade/result.json" ] && exit 0
line=$(awk -F'\t' -v r="$rid" '$1==r' "$P/plan.tsv"); proj=$(echo "$line" | cut -f2); task=$(echo "$line" | cut -f3)
bash "$STUDY_ROOT/harness/env/grade-dir.sh" "$proj" "$STUDY_ROOT/tasks/$proj/$task" "$out/patch.diff" "$out/grade" > "$out/grade.log" 2>&1 || true
echo "[env] graded $rid: $(cat "$out/grade/result.json" 2>/dev/null || echo none)" >&2
