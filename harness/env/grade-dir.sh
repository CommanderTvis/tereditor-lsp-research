# grade-dir.sh <project> <task-dir> <patch> <out-dir>: grade one patch in the grading sandbox, without network.
set -eu
. "$STUDY_ROOT/harness/env/lib.sh"
proj=$1 task=$2 patch=$3 out=$4
st=$STUDY_STATE/projects/$proj; [ -d "$st/snapshot" ] || die "project $proj is not set up: ./study project $proj"
mkdir -p "$out"; scratch=$(mktemp -d "$STUDY_STATE/scratch-XXXXXX")
GRADE_BINDS=(--ro-bind "$task" /task --ro-bind "$STUDY_ROOT/projects/$proj" /project --ro-bind "$STUDY_ROOT/harness/grade" /grade
             --ro-bind-try "$st/grade-overlay" /grade-overlay --ro-bind "$(dirname "$patch")" /run --bind "$out" /out --bind "$scratch" /scratch --setenv STUDY_WORK /scratch/work)
( grade_exec nonet "$st/snapshot" "$st/grade-home" /bin/sh /grade/grade.sh "/run/$(basename "$patch")" ) || true
rm -rf "$scratch"
[ -n "${STUDY_HOST_UID:-}" ] && chown -R "$STUDY_HOST_UID:${STUDY_HOST_GID:-$STUDY_HOST_UID}" "$out" 2>/dev/null || true
cat "$out/result.json" 2>/dev/null || echo '{"success":false,"error":"grader produced no result"}'
