# validate.sh <project>: every task's starting state fails the grader and its reference solution passes, twice.
set -eu
proj=$1; V=$STUDY_STATE/validate/$proj
for task in "$STUDY_ROOT/tasks/$proj"/*/; do
  task=${task%/}; id=$(basename "$task"); v=$V/$id; rm -rf "$v"; mkdir -p "$v"; : > "$v/empty.diff"
  if [ -f "$task/gold.patch" ]; then cp "$task/gold.patch" "$v/gold.diff"
  else
    printf 'diff --git a/ANSWER.txt b/ANSWER.txt\nnew file mode 100644\n--- /dev/null\n+++ b/ANSWER.txt\n@@ -0,0 +1,%s @@\n' \
      "$(wc -l < "$task/oracle.txt" | tr -d ' ')" > "$v/gold.diff"
    sed 's/^/+/' "$task/oracle.txt" >> "$v/gold.diff"
  fi
  r() { bash "$STUDY_ROOT/harness/env/grade-dir.sh" "$proj" "$task" "$1" "$2" 2>/dev/null | sed -n 's/.*"success":\([a-z]*\).*/\1/p' | tail -n1; }
  s=$(r "$v/empty.diff" "$v/start"); g1=$(r "$v/gold.diff" "$v/gold1"); g2=$(r "$v/gold.diff" "$v/gold2")
  ok=VALID; [ "$s" = false ] && [ "$g1" = true ] && [ "$g2" = true ] || ok=INVALID
  echo "$ok $proj/$id start=$s gold=$g1,$g2"
done
