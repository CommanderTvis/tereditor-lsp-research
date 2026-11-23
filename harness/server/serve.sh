#!/bin/sh
# The language server of one agent run, inside the server sandbox: headless tereditor on stdin and stdout.
# TEREDITOR_MODE: optional (its advice to prefer its tools is removed by neutral.jq) or enforced (as shipped).
# TEREDITOR_INTELLIJ=1: the IntelliJ server serves .kt and .java, with the terms accepted when the cache was warmed.
set -eu
export TEREDITOR_TOOLCHAINS=managed TEREDITOR_MANAGED_CACHE=/cache/managed TEREDITOR_STATE_DIR=/cache/state \
  TEREDITOR_ROOT=/workspace DOTNET_NOLOGO=1 DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0='*' \
  TEREDITOR_TOOLS_ALLOW=lsp_navigate,lsp_diagnostics,lsp_status,lsp_code_actions,lsp_rename,lsp_format \
  TEREDITOR_LOG=1 TEREDITOR_LOG_LEVEL=args TEREDITOR_RUNS_DIR=/study/lsplog
if [ "${TEREDITOR_INTELLIJ:-0}" = 1 ]; then
  [ -f /cache/study-intellij.env ] || { echo "serve.sh: the cache has no IntelliJ acceptance (warm the jvm group)" >&2; exit 2; }
  . /cache/study-intellij.env
  export TEREDITOR_PREFETCH=intellij TEREDITOR_ACCEPT_TERMS="intellij:$INTELLIJ_TERMS_HASH" INTELLIJ_REGION INTELLIJ_DATA_SHARING
fi
# Behind a TLS-re-signing egress proxy (a cloud session) the JVM tools that IntelliJ's Maven import starts get neither
# JAVA_TOOL_OPTIONS nor the proxy's CA: Maven then fails with PKIX errors and IntelliJ has no project model. Maven's
# launcher reads ~/.mavenrc whatever environment it is started with, so the trust store goes there (no proxy, no file).
if [ -f /study/proxy-truststore ]; then
  printf '%s\n' 'MAVEN_OPTS="${MAVEN_OPTS:-} -Djavax.net.ssl.trustStore=/study/proxy-truststore -Djavax.net.ssl.trustStoreType=JKS"' > "$HOME/.mavenrc"
else rm -f "$HOME/.mavenrc"; fi
for lf in /study/license/license.zip /study/license/license.txt; do [ -f "$lf" ] && export INTELLIJ_SERVER_LICENSE_FILE="$lf"; done
case "$TEREDITOR_MODE" in
  enforced) exec /opt/tereditor/tereditor-headless mcp --workspace /workspace 2>>/study/lsplog/server.stderr ;;
  optional) /opt/tereditor/tereditor-headless mcp --workspace /workspace 2>>/study/lsplog/server.stderr \
              | jq -c --unbuffered -f /study/harness/neutral.jq ;;
  *) echo "serve.sh: unknown mode $TEREDITOR_MODE" >&2; exit 2 ;;
esac
