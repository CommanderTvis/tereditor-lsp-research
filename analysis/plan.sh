#!/bin/bash
# Writes results/<plan>/plan.tsv: one line per run, in a seeded random order (arms interleaved).
#   plan.sh <name> [--projects "python-small csharp-*"] [--models "claude-haiku-5-5 ..."] [--arms "baseline optional enforced"]
#                  [--reps N] [--reps-per-model "claude-haiku-5-5=3,claude-opus-5-5=1"] [--tasks "refs-*"]
#                  [--budget USD] [--turns N] [--timeout S] [--effort LEVEL|-] [--seed N]
# Runs in the study environment (harness/env/entry.sh), so the seeded shuffle is the same on every host.
set -euo pipefail
cd "$STUDY_ROOT"
name=$1; shift
projects="*"; models="claude-haiku-5-5 claude-sonnet-5-5 claude-opus-5-5"; arms="baseline optional enforced intellij-optional intellij-enforced"
reps=1; rpm=""; tasks="*"; budget=10; turns=200; timeout=3600; effort="-"; seed=20261110
while [ $# -gt 0 ]; do
  case "$1" in
    --projects) projects=$2 ;; --models) models=$2 ;; --arms) arms=$2 ;; --reps) reps=$2 ;; --reps-per-model) rpm=$2 ;;
    --tasks) tasks=$2 ;; --budget) budget=$2 ;; --turns) turns=$2 ;; --timeout) timeout=$2 ;; --effort) effort=$2 ;;
    --seed) seed=$2 ;; *) echo "plan.sh: unknown option $1" >&2; exit 2 ;;
  esac; shift 2
done
reps_for() { local m=$1 kv; for kv in ${rpm//,/ }; do [ "${kv%%=*}" = "$m" ] && { echo "${kv#*=}"; return; }; done; echo "$reps"; }
out=results/$name; mkdir -p "$out"
tmp=$(mktemp)
read -ra project_globs <<<"$projects"; read -ra task_globs <<<"$tasks"   # no expansion until joined to a path
for pglob in "${project_globs[@]}"; do
  for pd in tasks/$pglob/; do
    [ -d "$pd" ] || continue; proj=$(basename "$pd")
    for tglob in "${task_globs[@]}"; do for td in "$pd"$tglob/; do
      [ -f "$td/task.toml" ] || continue; task=$(basename "$td")
      for m in $models; do
        for r in $(seq 1 "$(reps_for "$m")"); do
          for a in $arms; do
            # Arm applicability (docs/DESIGN.md): IntelliJ arms only on JVM projects; Java has no server without IntelliJ.
            lang=${proj%-*}
            case "$a" in intellij-*) case "$lang" in kotlin|java|java-kotlin) ;; *) continue ;; esac ;; esac
            case "$a:$lang" in optional:java|enforced:java) continue ;; esac
            printf '%s\t%s\t%s\t%s\t%s\n' "$proj" "$task" "$a" "$m" "$r" >> "$tmp"; done
        done
      done
    done; done
  done
done
{
  printf 'run_id\tproject\ttask\tarm\tmodel\trep\teffort\tbudget_usd\tmax_turns\ttimeout_s\n'
  awk -v seed="$seed" 'BEGIN{srand(seed)} {printf "%.12f\t%s\n", rand(), $0}' "$tmp" | sort -k1,1n | cut -f2- \
  | awk -F'\t' -v e="$effort" -v b="$budget" -v t="$turns" -v s="$timeout" 'BEGIN{OFS="\t"}
      {n++; id=sprintf("r%05d", n); print id, $1, $2, $3, $4, $5, e, b, t, s}'
} > "$out/plan.tsv"
rm -f "$tmp"
