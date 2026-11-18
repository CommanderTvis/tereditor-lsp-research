#!/bin/bash
# Writes results/<plan>/plan.tsv: one line per run, in a seeded random order (arms interleaved).
#   plan.sh <name> [--projects "python-small csharp-*"] [--models "claude-haiku-5-5 ..."] [--arms "baseline optional enforced"]
#                  [--reps N] [--reps-per-model "claude-haiku-5-5=3,claude-opus-5-5=1"] [--model-fraction "claude-opus-5-5=0.5"] [--keep N] [--skip-arms "arm:lang ..."] [--tasks "refs-*"]
#                  [--budget USD] [--turns N] [--timeout S] [--effort LEVEL|-] [--seed N]
# Runs in the study environment (harness/env/entry.sh), so the seeded shuffle is the same on every host.
set -euo pipefail
cd "$STUDY_ROOT"
name=$1; shift
projects="*"; models="claude-haiku-5-5 claude-sonnet-5-5 claude-opus-5-5"; arms="baseline baseline-review optional enforced intellij-optional intellij-enforced"
reps=1; rpm=""; mfrac=""; keep=0; skip=""; tasks="*"; budget=3; turns=200; timeout=3600; effort="-"; seed=20261110
while [ $# -gt 0 ]; do
  case "$1" in
    --projects) projects=$2 ;; --models) models=$2 ;; --arms) arms=$2 ;; --reps) reps=$2 ;; --reps-per-model) rpm=$2 ;; --model-fraction) mfrac=$2 ;; --keep) keep=$2 ;; --skip-arms) skip=$2 ;;
    --tasks) tasks=$2 ;; --budget) budget=$2 ;; --turns) turns=$2 ;; --timeout) timeout=$2 ;; --effort) effort=$2 ;;
    --seed) seed=$2 ;; *) echo "plan.sh: unknown option $1" >&2; exit 2 ;;
  esac; shift 2
done
# --model-fraction "claude-opus-5-5=0.5": that model runs only on a fixed, seeded fraction of the tasks, the same tasks for
# every arm and repetition (a hash of seed, project and task), so the pairing across arms is kept.
frac_for() { local m=$1 kv; for kv in ${mfrac//,/ }; do [ "${kv%%=*}" = "$m" ] && { echo "${kv#*=}"; return; }; done; echo 1; }
in_subset() { local f; f=$(frac_for "$1"); [ "$f" = 1 ] && return 0; local h; h=$(printf '%s/%s/%s' "$seed" "$2" "$3" | cksum | cut -d" " -f1); awk -v h="$h" -v f="$f" 'BEGIN{exit !((h % 10000) / 10000 < f)}'; }
# --keep N: only N tasks per project, one round of refactoring, navigation, mined PR in that order (then a second round),
# each group ordered by a hash of seed, project and task, so nobody picks. A project with no mined PR gets a second
# refactoring in its place. 0 keeps every task.
kept_tasks() { local pd=$1 proj td t ty g h; proj=$(basename "$pd")
  for td in "$pd"*/; do [ -f "$td/task.toml" ] || continue; t=$(basename "$td")
    ty=$(sed -n 's/^type[[:space:]]*=[[:space:]]*"\([a-z-]*\)".*/\1/p' "$td/task.toml" | head -n1)
    case "$ty" in pr) g=3 ;; refs|impls|dispatch|callers|inspect) g=2 ;; *) g=1 ;; esac
    h=$(printf '%s/%s/%s' "$seed" "$proj" "$t" | cksum | cut -d" " -f1)
    printf '%s %s %s\n' "$g" "$h" "$t"
  done | sort -k1,1n -k2,2n | awk -v n="$keep" '{c[$1]++; name[$1, c[$1]]=$3}
    END {p=0; for (r=1; p<n && r<=20; r++) for (g=1; g<=3 && p<n; g++) if (r<=c[g]) {print name[g, r]; p++}}'; }
reps_for() { local m=$1 kv; for kv in ${rpm//,/ }; do [ "${kv%%=*}" = "$m" ] && { echo "${kv#*=}"; return; }; done; echo "$reps"; }
out=results/$name; mkdir -p "$out"
tmp=$(mktemp)
read -ra project_globs <<<"$projects"; read -ra task_globs <<<"$tasks"   # no expansion until joined to a path
for pglob in "${project_globs[@]}"; do
  for pd in tasks/$pglob/; do
    [ -d "$pd" ] || continue; proj=$(basename "$pd")
    keptlist=""; [ "$keep" != 0 ] && keptlist=" $(kept_tasks "$pd" | tr '\n' ' ') "
    for tglob in "${task_globs[@]}"; do for td in "$pd"$tglob/; do
      [ -f "$td/task.toml" ] || continue; task=$(basename "$td")
      [ -z "$keptlist" ] || case "$keptlist" in *" $task "*) ;; *) continue ;; esac
      for m in $models; do
        in_subset "$m" "$proj" "$task" || continue
        for r in $(seq 1 "$(reps_for "$m")"); do
          for a in $arms; do
            # Arm applicability (docs/DESIGN.md): IntelliJ arms only on JVM projects; Java has no server without IntelliJ.
            lang=${proj%-*}
            case "$a" in intellij-*) case "$lang" in kotlin|java|java-kotlin) ;; *) continue ;; esac ;; esac
            case "$a:$lang" in optional:java|enforced:java) continue ;; esac
            case " $skip " in *" $a:$lang "*) continue ;; esac   # --skip-arms "optional:kotlin enforced:kotlin ..."
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
