#!/bin/bash
# Host side (run as: env script via harness/env/entry.sh jvm ../../tasks/java-large/refs-invalidformatexception-from/derive-run):
# runs derive-oracle.sh in the grading sandbox on the project's pinned snapshot, with network off.
set -eu
. "$STUDY_ROOT/harness/env/lib.sh"
proj=java-large; task=$STUDY_ROOT/tasks/$proj/refs-invalidformatexception-from
st=$(state_dir "$proj" "$(project_commit "$proj")")
GRADE_BINDS=(--ro-bind "$task" /task --chdir /study/snapshot)
grade_exec nonet "$st/snapshot" "$st/grade-home" /bin/sh /task/derive-oracle.sh
