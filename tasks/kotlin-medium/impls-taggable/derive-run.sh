#!/bin/bash
# Host side (run as: env script via harness/env/entry.sh jvm ../../tasks/kotlin-medium/impls-taggable/derive-run):
# runs derive-oracle.sh in the grading sandbox on a copy of the project's pinned snapshot, with network off; the oracle is
# printed on stdout.
set -eu
. "$STUDY_ROOT/harness/env/lib.sh"
proj=kotlin-medium; task=$STUDY_ROOT/tasks/$proj/impls-taggable
st=$(state_dir "$proj" "$(project_commit "$proj")")
scratch=$(mktemp -d "$STUDY_STATE/scratch-XXXXXX"); cp -a "$st/snapshot" "$scratch/work"
[ -d "$st/grade-overlay" ] && cp -a "$st/grade-overlay/." "$scratch/work/"
GRADE_BINDS=(--ro-bind "$task" /task --bind "$scratch" /scratch --chdir /scratch/work)
grade_exec nonet "$st/snapshot" "$st/grade-home" /bin/sh -c 'sh /task/derive-oracle.sh'
rm -rf "$scratch"
