#!/bin/sh
set -eu
sort -u ANSWER.txt > .study-answer
sort -u "$TASK_DIR/oracle.txt" > .study-oracle
diff -u .study-oracle .study-answer
