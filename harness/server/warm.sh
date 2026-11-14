#!/bin/sh
# Inside the server sandbox: install the language servers of a group into /cache (network on). For the JVM group also
# record the acceptance of the IntelliJ server's terms (harness/intellij.env, passed as INTELLIJ_*).
set -eu
export TEREDITOR_TOOLCHAINS=managed TEREDITOR_MANAGED_CACHE=/cache/managed TEREDITOR_STATE_DIR=/cache/state
/opt/tereditor/tereditor-headless warm "$@" --workspace /workspace
if [ -n "${INTELLIJ_TERMS_HASH:-}" ]; then
  TEREDITOR_PREFETCH=intellij TEREDITOR_ACCEPT_TERMS="intellij:$INTELLIJ_TERMS_HASH" \
    /opt/tereditor/tereditor-headless warm intellij --workspace /workspace
  printf 'INTELLIJ_TERMS_HASH=%s\nINTELLIJ_REGION=%s\nINTELLIJ_DATA_SHARING=%s\n' \
    "$INTELLIJ_TERMS_HASH" "$INTELLIJ_REGION" "$INTELLIJ_DATA_SHARING" > /cache/study-intellij.env
fi
