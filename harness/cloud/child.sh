#!/bin/sh
# child.sh <project> <plan>: one project of the operator's plan in a helper cloud session, end to end, results to the
# operator's S3 bucket (docs/CLOUD_PARALLEL.md). Started by the helper session's prompt (harness/cloud/prompt.tmpl),
# with s3.sh next to it and S3_ENDPOINT, S3_REGION, S3_ACCESS and S3_SECRET in the environment. Idempotent: run it again
# after an interruption and it continues (finished runs and gradings are skipped by ./study).
# Bucket keys: control/ (written by ./study cloud launch) and <plan>/<project>/ (written here).
set -u
P=$1 PLAN=$2
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/s3.sh"
s3_check || exit 2
D=${CHILD_DIR:-/root}
W=$D/study-$PLAN-$P
LOG=$D/child-$P.log
ST=$D/child-$P.status.json
K=$PLAN/$P
# A claim identity unique per VM (every cloud VM has the same host name), kept across restarts of this script.
[ -s "$D/child-$P.me" ] || echo "$(hostname)-$(cut -c1-8 /proc/sys/kernel/random/boot_id)" > "$D/child-$P.me"
ME=$(cat "$D/child-$P.me")
now() { date -u +%FT%TZ; }
status() { # status <state> <step> <detail>
  printf '{"project":"%s","plan":"%s","state":"%s","step":"%s","detail":"%s","time":"%s","host":"%s"}\n' \
    "$P" "$PLAN" "$1" "$2" "$(printf '%s' "$3" | tr '"\n\\' "'  " | cut -c1-500)" "$(now)" "$ME" > "$ST"
  s3_put "$ST" "$K/status.json" || true
}
logtail() { tail -c 200000 "$LOG" > "$D/child-$P.logtail"; s3_put "$D/child-$P.logtail" "$K/log-tail.txt" || true; }
fail() { status failed "$1" "$2"; logtail; exit 1; }
exec >>"$LOG" 2>&1
echo "== child.sh $P $PLAN start $(now)"

# Heartbeat every 5 minutes until this script exits: time first (./study cloud status reads it), then the runs' state.
( while sleep 300; do
    n=0; g=0
    for f in "$W/results/$PLAN"/runs/*/exit.json; do if [ -f "$f" ]; then n=$((n+1)); fi; done
    for f in "$W/results/$PLAN"/runs/*/grade/result.json; do if [ -f "$f" ]; then g=$((g+1)); fi; done
    printf '%s finished=%s graded=%s disk_free=%s\n' "$(now)" "$n" "$g" "$(df -h / | tail -1 | awk '{print $4}')" > "$D/child-$P.hb"
    s3_put "$D/child-$P.hb" "$K/heartbeat.txt" || true
  done ) &
HB=$!
trap 'kill $HB 2>/dev/null' EXIT

# One worker per project: a project whose status.json in the bucket names another host belongs to that host.
owner=$(s3_try "$K/status.json" | json_field host)
if [ -n "$owner" ] && [ "$owner" != "$ME" ]; then
  echo "== $P is claimed by $owner; nothing to do"
  printf '{"project":"%s","plan":"%s","state":"skipped","detail":"claimed by %s"}\n' "$P" "$PLAN" "$owner" > "$ST"
  exit 0
fi

status running checkout ""
if [ ! -d "$W/.git" ]; then
  s3_get control/branch.txt "$D/branch.txt" || fail checkout "cannot download control/branch.txt"
  s3_get control/study.bundle "$D/study.bundle" || fail checkout "cannot download control/study.bundle"
  git clone -q -b "$(cat "$D/branch.txt")" "$D/study.bundle" "$W" || fail checkout "git clone from the bundle failed"
fi
cd "$W" || fail checkout "no checkout"
git config user.name "Claude Code cloud session"; git config user.email noreply@anthropic.com

l=${P%-*}; case "$l" in kotlin|java|java-kotlin) g=jvm ;; *) g=$l ;; esac
export STUDY_RUNTIME=native STUDY_CPUS=3 STUDY_MEMORY=10g; j=2
case "$P" in *-xlarge) STUDY_MEMORY=14g; j=1 ;; esac

# The plan is the operator's (results/ is not in the repository), uploaded by ./study cloud launch, never regenerated here.
status running plan ""
want=$(s3_try control/plan.sha256 | cut -c1-64)
[ -n "$want" ] || fail plan "cannot download control/plan.sha256"
mkdir -p "results/$PLAN"
[ -f "results/$PLAN/plan.tsv" ] || s3_get control/plan.tsv "results/$PLAN/plan.tsv" || fail plan "cannot download control/plan.tsv"
sha=$(sha256_of "results/$PLAN/plan.tsv")
[ "$sha" = "$want" ] || fail plan "plan.tsv sha256 $sha differs from the operator's $want"
ids=$(awk -F'\t' -v p="$P" 'NR>1 && $2==p {print $1}' "results/$PLAN/plan.tsv")
[ -n "$ids" ] || fail plan "$P has no runs in results/$PLAN/plan.tsv"

status running setup ""
./study setup "$g" || fail setup "./study setup $g failed"
status running project ""
./study project "$P" || fail project "./study project $P failed"
# The JetBrains licence: ./study cloud launch uploads it to control/license.zip; wait for it (up to 24 h).
t=0
until [ -s license.zip ]; do
  s3_try control/license.zip > license.zip || rm -f license.zip
  [ -s license.zip ] && break
  status waiting licence "waiting for control/license.zip in the bucket"
  t=$((t+300)); [ $t -lt 86400 ] || fail licence "no licence at control/license.zip after 24 h"
  sleep 300
done
chmod 600 license.zip
status running run ""
./study run "$PLAN" --project "$P" -j "$j" || echo "run exited $?"
status running grade ""
./study grade "$PLAN" --project "$P" -j "$j" || echo "grade exited $?"
# The Haiku quality review, where the driver of this branch has it.
if grep -q '^  review)' study; then
  status running review ""
  ./study review "$PLAN" --project "$P" -j 2 || echo "review exited $?"
fi
status running archive ""
./study archive "$PLAN" "$P" || fail archive "./study archive failed"
[ -f "results/$PLAN/archive/$P.tar.gz" ] || fail archive "no finished runs to archive"
status running upload ""
s3_put "results/$PLAN/archive/$P.tar.gz" "$K/$P.tar.gz" || fail upload "archive upload failed"
[ -f "results/$PLAN/limit-attempts.log" ] && s3_put "results/$PLAN/limit-attempts.log" "$K/limit-attempts.log"

# Verify: every planned run finished and graded, and none kept that stopped on a usage limit (harness/cloud/scan.sh).
planned=$(echo "$ids" | wc -l | tr -d ' ')
fin=0; grd=0
for r in $ids; do
  if [ -f "results/$PLAN/runs/$r/exit.json" ]; then fin=$((fin+1)); fi
  if [ -f "results/$PLAN/runs/$r/grade/result.json" ]; then grd=$((grd+1)); fi
done
# shellcheck disable=SC2086
scan=$(bash harness/cloud/scan.sh "results/$PLAN/runs" $ids); scan_ok=$?
cost=$(cat "results/$PLAN"/runs/*/stream.jsonl "results/$PLAN"/runs/*/stream-review.jsonl 2>/dev/null \
  | jq -s '[.[] | select(type=="object" and .type=="result") | .total_cost_usd // 0] | add // 0' 2>/dev/null || echo "?")
logtail
if [ "$fin" = "$planned" ] && [ "$grd" = "$planned" ] && [ "$scan_ok" = 0 ]; then st="done"; else st="incomplete"; fi
status "$st" finished "planned=$planned finished=$fin graded=$grd $scan agent_cost_usd=$cost"
./study prune "$P" || true
echo "== child.sh $P $PLAN end $(now) $st"
