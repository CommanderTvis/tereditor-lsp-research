#!/bin/bash
# redteam.sh: attacks the agent's sandbox from the inside (harness/redteam/attack.sh) with the same egress proxy and
# the same mounts as a real run, no model and no credentials. Exit 1 if any attack worked.
set -euo pipefail
. "$STUDY_ROOT/harness/env/lib.sh"
w=$(mktemp -d "$STUDY_STATE/redteam-XXXXXX"); mkdir -p "$w/ws" "$w/home" "$w/in" "$w/sock" "$w/lic"; chmod 0777 "$w/sock"
canary=REDTEAM-CANARY-$(date +%s)-$RANDOM$RANDOM
# Stand-ins for the gold patch, in the places the real ones live (tasks/, the state dir, results/).
for d in "$STUDY_ROOT/tasks/.redteam" "$STUDY_STATE/redteam-secret" "$STUDY_ROOT/results/.redteam"; do mkdir -p "$d"; echo "$canary" > "$d/gold.patch"; done
cleanup() { [ -n "${egress:-}" ] && kill "$egress" 2>/dev/null || true
  rm -rf "$STUDY_ROOT/tasks/.redteam" "$STUDY_STATE/redteam-secret" "$STUDY_ROOT/results/.redteam" "$w"; }
trap cleanup EXIT
g() { git -c user.name=study -c user.email=study@localhost "$@"; }
echo "fixed" > "$w/ws/README"; g -C "$w/ws" init -q -b main; g -C "$w/ws" add -A; g -C "$w/ws" commit -qm redteam
cp "$STUDY_ROOT/harness/redteam/attack.sh" "$w/in/attack.sh"
socat UNIX-LISTEN:"$w/sock/egress.sock",fork,mode=0777 EXEC:"bash $STUDY_ROOT/harness/env/egress-conn.sh $w/egress.log" &
egress=$!
for _ in $(seq 1 50); do [ -S "$w/sock/egress.sock" ] && break; sleep 0.1; done
AGENT_ENV=(DISABLE_AUTOUPDATER=1)
set +e
( agent_exec "$w/ws" "$w/home" "$w/in" "$w/sock" bash /in/attack.sh "$canary" ) | tee "$STUDY_ROOT/results/redteam.txt"
rc=${PIPESTATUS[0]}
echo "--- egress log ---"; cat "$w/egress.log" 2>/dev/null || true
[ -n "${STUDY_HOST_UID:-}" ] && chown "$STUDY_HOST_UID:${STUDY_HOST_GID:-$STUDY_HOST_UID}" "$STUDY_ROOT/results/redteam.txt" 2>/dev/null
echo "redteam: $([ "$rc" = 0 ] && echo 'all attacks blocked' || echo 'AN ATTACK WORKED')"
exit "$rc"
