# run-many.sh <run|grade> <plan> <parallel> <run-id>...: several runs (or gradings) of one language group, N at a
# time, inside one environment (an Apple container volume can be attached to one container at a time).
set -eu
what=$1 plan=$2 j=$3; shift 3
[ $# -gt 0 ] || exit 0
printf '%s\n' "$@" | xargs -P "$j" -n 1 bash "$STUDY_ROOT/harness/env/$what-one.sh" "$plan"
