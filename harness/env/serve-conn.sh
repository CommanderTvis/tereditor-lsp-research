# serve-conn.sh <mode> <workspace> <lsplog> <license-dir>: one MCP connection from the agent's socket (socat runs this
# per connection): the language server's sandbox on this stdin and stdout.
set -eu
. "$STUDY_ROOT/harness/env/lib.sh"
server_exec "$@"
