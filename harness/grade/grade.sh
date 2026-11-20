#!/bin/sh
# Grades one run in the grading sandbox (no network). Needs only sh, git, awk, sort, comm, timeout.
#   /task     the task directory (task.toml, setup.patch, hidden/, oracle.txt, grade.sh)
#   /project  the project directory (check.sh: build + tests, run in the patched tree)
#   $1        the run's patch (git diff against the starting state)
# Writes /out/result.json and /out/check.log.
set -u
patch=$1
out=/out; mkdir -p "$out"
type=$(sed -n 's/^type[[:space:]]*=[[:space:]]*"\([a-z-]*\)".*/\1/p' /task/task.toml | head -n1)
timeout_s=$(sed -n 's/^grade_timeout_s[[:space:]]*=[[:space:]]*\([0-9]*\).*/\1/p' /task/task.toml | head -n1)
[ -n "$timeout_s" ] || timeout_s=1800
start=$(date +%s)
result() { # success extra-json
  printf '{"type":"%s","success":%s,"seconds":%s%s}\n' "$type" "$1" "$(( $(date +%s) - start ))" "$2" > "$out/result.json"
  cat "$out/result.json"
  [ -n "${STUDY_HOST_UID:-}" ] && chown -R "$STUDY_HOST_UID:${STUDY_HOST_GID:-$STUDY_HOST_UID}" "$out" 2>/dev/null
  exit 0
}

work=${STUDY_WORK:-/work}
rm -rf "$work" && cp -a /study/snapshot "$work" && cd "$work" || exit 1
[ -d /grade-overlay ] && cp -a /grade-overlay/. "$work/"
git() { command git -c user.name=grader -c user.email=grader@localhost "$@"; }
# Some upstream trees are committed with CRLF line endings and the study's reference patches carry LF context: when the
# strict apply fails, the patch is applied again ignoring whitespace in the context lines.
apply() { git apply --whitespace=nowarn "$1" 2>"${2:-/dev/null}" || git apply --whitespace=nowarn --ignore-whitespace "$1" 2>"${2:-/dev/null}"; }
if [ -s /task/setup.patch ]; then apply /task/setup.patch || result false ',"error":"setup.patch does not apply"'; fi
applied=true
if [ -s "$patch" ]; then apply "$patch" "$out/apply.log" || applied=false; fi
[ "$applied" = true ] || result false ',"patch_applied":false'

case "$type" in
  refs|impls|dispatch|callers|inspect)
    norm() { sed -e 's/\r$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's|^\./||' -e 's|^/workspace/||' | grep -v '^$' | sort -u; }
    norm < /task/oracle.txt > "$out/oracle.norm"
    if [ -f ANSWER.txt ]; then norm < ANSWER.txt > "$out/answer.norm"; else : > "$out/answer.norm"; fi
    tp=$(comm -12 "$out/oracle.norm" "$out/answer.norm" | wc -l | tr -d ' ')
    fp=$(comm -13 "$out/oracle.norm" "$out/answer.norm" | wc -l | tr -d ' ')
    fn=$(comm -23 "$out/oracle.norm" "$out/answer.norm" | wc -l | tr -d ' ')
    metrics=$(awk -v tp="$tp" -v fp="$fp" -v fn="$fn" 'BEGIN{p=(tp+fp)?tp/(tp+fp):0; r=(tp+fn)?tp/(tp+fn):0; f=(p+r)?2*p*r/(p+r):0; printf ",\"tp\":%d,\"fp\":%d,\"fn\":%d,\"precision\":%.4f,\"recall\":%.4f,\"f1\":%.4f", tp, fp, fn, p, r, f}')
    ok=false; [ "$fp" = 0 ] && [ "$fn" = 0 ] && [ "$tp" -gt 0 ] && ok=true
    result "$ok" "$metrics,\"answer_present\":$([ -f ANSWER.txt ] && echo true || echo false)"
    ;;
  rename|rename-file|move|signature|compile|bugfix|pr)
    [ -d /task/hidden ] && cp -R /task/hidden/. "$work/"
    if [ -f /task/grade.sh ]; then check=/task/grade.sh; else check=/project/check.sh; fi
    TASK_DIR=/task timeout "$timeout_s" sh "$check" > "$out/check.log" 2>&1
    rc=$?
    ok=false; [ "$rc" = 0 ] && ok=true
    result "$ok" ",\"check_exit\":$rc,\"patch_applied\":true"
    ;;
  *) result false ",\"error\":\"unknown task type '$type'\"" ;;
esac
