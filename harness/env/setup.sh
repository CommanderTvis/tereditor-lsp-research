# setup.sh: tereditor from its pinned image, and the language servers of this group in the cache (once; network on).
set -eu
. "$STUDY_ROOT/harness/env/lib.sh"
if [ ! -x "$TEREDITOR_DIR/tereditor-headless" ]; then
  log "tereditor $TEREDITOR_COMMIT from its image"; bash "$STUDY_ROOT/harness/env/fetch-tereditor.sh" "$TEREDITOR_DIR"
fi
case "$STUDY_GROUP" in cpp) servers=clangd ;; jvm) servers=kotlin ;; *) servers=$STUDY_GROUP ;; esac
[ -f "$CACHE/.warm-$STUDY_GROUP" ] && { log "servers of $STUDY_GROUP already installed"; exit 0; }
tmp=$(mktemp -d); mkdir -p "$tmp/ws" "$tmp/log" "$tmp/lic"
if [ "$STUDY_GROUP" = jvm ]; then
  while IFS='=' read -r k v; do case "$k" in INTELLIJ_*) SERVER_ENV+=("$k=$v") ;; esac; done < "$STUDY_ROOT/harness/intellij.env"
fi
log "installing $servers${SERVER_ENV[*]:+ and intellij} into the cache"
( server_exec enforced "$tmp/ws" "$tmp/log" "$tmp/lic" /bin/sh /study/harness/warm.sh $servers )
touch "$CACHE/.warm-$STUDY_GROUP"; rm -rf "$tmp"
