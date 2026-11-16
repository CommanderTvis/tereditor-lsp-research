# Sourced by the harness scripts (bash). The three sandboxes of a run, built with bubblewrap from Nix closures:
#   agent   only the agent closure (core utilities, git, ripgrep, jq, socat, Claude Code); no compiler exists in it
#   server  the server's FHS-shaped root, tereditor and its runtime cache; the agent reaches it only through a socket
#   grade   one language's toolchain, the project and the task, no network
# Every sandbox runs without capabilities in its own PID, IPC and UTS namespaces, with a private /tmp and an empty
# environment.

log() { echo "[env $(date -u +%H:%M:%S)] $*" >&2; }
die() { echo "env: $*" >&2; exit 2; }

TEREDITOR_COMMIT=$(sed -n 's/^TEREDITOR_COMMIT=//p' "$STUDY_ROOT/harness/tereditor.env")
TEREDITOR_DIR="$STUDY_STATE/tereditor/$TEREDITOR_COMMIT-$(uname -m)"
# Everything built on a machine (language-server caches, managed runtimes, prepared snapshots) is keyed by its
# architecture, so an amd64 and an arm64 builder can share one state volume without overwriting each other.
CACHE="$STUDY_STATE/cache-$(uname -m)"
mkdir -p "$CACHE/home" "$CACHE/managed" "$CACHE/state"
# The commit a task starts from: its task.toml's base_commit (a mined pull request), else the project's pinned commit;
# and the state directory of a project at a commit (snapshot, grading home and overlay, setup markers).
toml_val() { sed -n "s/^$2[[:space:]]*=[[:space:]]*\"\{0,1\}\([^\"]*\)\"\{0,1\}[[:space:]]*\$/\1/p" "$1" 2>/dev/null | head -n1; }
project_commit() { toml_val "$STUDY_ROOT/projects/$1/project.toml" commit; }
task_commit() { local c; c=$(toml_val "$2/task.toml" base_commit); [ -n "$c" ] && echo "$c" || project_commit "$1"; }
state_dir() { echo "$STUDY_STATE/projects-$(uname -m)/$1/$2"; }

# Extra environment (NAME=value) and binds a caller adds to a sandbox.
SERVER_ENV=(); AGENT_ENV=(); GRADE_BINDS=()

# Arguments accumulate in the array A; each sandbox function ends with `exec bwrap "${A[@]}" cmd...`.
closure_binds() { local p; while IFS= read -r p; do A+=(--ro-bind "$p" "$p"); done < "$1"; }

# etc_dir <dir> <user> <uid> <home>: a minimal /etc for a sandbox.
etc_dir() {
  mkdir -p "$1/ssl"
  # No separate root entry for a uid-0 sandbox user: getpwuid(0) must return its home (Java's user.home, so ~/.m2).
  { [ "$3" = 0 ] || printf 'root:x:0:0:root:/root:/bin/sh\n'; printf '%s:x:%s:%s:%s:%s:/bin/bash\n' "$2" "$3" "$3" "$2" "$4"; } > "$1/passwd"
  { [ "$3" = 0 ] || printf 'root:x:0:\n'; printf '%s:x:%s:\n' "$2" "$3"; } > "$1/group"
  printf '127.0.0.1 localhost\n::1 localhost\n' > "$1/hosts"
  cp /etc/resolv.conf "$1/resolv.conf" 2>/dev/null || printf 'nameserver 1.1.1.1\n' > "$1/resolv.conf"
  printf 'hosts: files dns\npasswd: files\ngroup: files\n' > "$1/nsswitch.conf"
}

# proxy_args: behind an egress proxy that re-signs TLS (a Claude Code cloud session) a sandbox with network must be
# told about the proxy and trust its CA (the cloud session sets HTTPS_PROXY and CURL_CA_BUNDLE). Maven's repository
# prefix filter probes with requests such a proxy answers 404, which hides real artifacts, so it is turned off.
proxy_args() {
  [ -n "${HTTPS_PROXY:-}" ] && [ -f "${CURL_CA_BUNDLE:-}" ] || return 0
  A+=(--ro-bind "$CURL_CA_BUNDLE" /study/proxy-ca.crt --setenv HTTPS_PROXY "$HTTPS_PROXY" --setenv https_proxy "$HTTPS_PROXY"
      --setenv NO_PROXY "${NO_PROXY:-}" --setenv no_proxy "${NO_PROXY:-}" --setenv SSL_CERT_FILE /study/proxy-ca.crt
      --setenv NODE_EXTRA_CA_CERTS /study/proxy-ca.crt)
  local jto=${JAVA_TOOL_OPTIONS:-} ts
  ts=$(printf '%s' "$jto" | sed -n 's/.*-Djavax.net.ssl.trustStore=\([^ ]*\).*/\1/p')
  if [ -n "$ts" ] && [ -f "$ts" ]; then A+=(--ro-bind "$ts" /study/proxy-truststore); jto=${jto//$ts//study/proxy-truststore}; fi
  A+=(--setenv JAVA_TOOL_OPTIONS "$jto -Daether.remoteRepositoryFilter.prefixes=false")
}

# Root without capabilities, in its own PID, IPC and UTS namespaces: what a sandbox can reach is decided by what is
# mounted into it, and without capabilities nothing inside can mount or remount. (A user namespace would also map
# uids, but inside a container it forbids mounting a fresh /proc.)
base_args() {
  A=(--unshare-ipc --unshare-uts --unshare-pid --die-with-parent --cap-drop ALL
     --proc /proc --dev /dev --tmpfs /tmp --clearenv)
}

# server_exec <mode> <workspace> <lsplog-dir> <license-dir> [cmd...]: the language server's sandbox.
# Without a command it serves MCP on stdin and stdout (harness/server/serve.sh).
server_exec() {
  local mode=$1 ws=$2 lsplog=$3 licdir=$4 intellij=0 etc; shift 4
  [ -x "$TEREDITOR_DIR/tereditor-headless" ] || die "tereditor is missing ($TEREDITOR_DIR): run ./study setup"
  case "$mode" in intellij-*) intellij=1; mode=${mode#intellij-} ;; esac
  etc=$(mktemp -d); etc_dir "$etc" tereditor 0 /cache/home
  base_args
  closure_binds "$STUDY_SERVER_CLOSURE"
  [ -n "${STUDY_JVM_CLOSURE:-}" ] && closure_binds "$STUDY_JVM_CLOSURE"
  A+=(--ro-bind "$STUDY_SERVER_FHS/bin" /bin --ro-bind "$STUDY_SERVER_FHS/bin" /usr/bin
      --ro-bind "$STUDY_SERVER_FHS/lib" /lib --ro-bind "$STUDY_SERVER_FHS/lib" /lib64 --ro-bind "$STUDY_SERVER_FHS/lib" /usr/lib
      --ro-bind "$etc" /etc --ro-bind "$STUDY_SERVER_FHS/etc/ssl" /etc/ssl
      --ro-bind "$TEREDITOR_DIR" /opt/tereditor --bind "$CACHE" /cache --bind "$ws" /workspace
      --bind "$lsplog" /study/lsplog --ro-bind "$licdir" /study/license --ro-bind "$STUDY_ROOT/harness/server" /study/harness
      --chdir /workspace --setenv HOME /cache/home --setenv PATH "/bin${STUDY_JVM:+:$STUDY_JVM/bin}"
      --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt --setenv TEREDITOR_MODE "$mode" --setenv TEREDITOR_INTELLIJ "$intellij")
  # .NET looks for ICU under versioned names; tell tereditor and the .NET SDK it manages which one the root has.
  local icu; icu=$(ls "$STUDY_SERVER_FHS/lib" | sed -n 's/^libicuuc\.so\.\([0-9][0-9]*\)$/\1/p' | head -n1)
  [ -n "$icu" ] && A+=(--setenv CLR_ICU_VERSION_OVERRIDE "$icu")
  # Nix's glibc searches only its own store directory by default, so libraries opened at run time (ICU, libstdc++ of
  # the downloaded runtimes) are found through /lib explicitly.
  A+=(--setenv LD_LIBRARY_PATH /lib)
  [ -n "${STUDY_JVM:-}" ] && A+=(--setenv JAVA_HOME "$STUDY_JVM/lib/openjdk")
  proxy_args
  local kv; for kv in "${SERVER_ENV[@]}"; do A+=(--setenv "${kv%%=*}" "${kv#*=}"); done
  [ $# -gt 0 ] || set -- /bin/sh /study/harness/serve.sh
  exec bwrap "${A[@]}" "$@"
}

# grade_exec <net|nonet> <snapshot> <grade-home> cmd...: the grader's sandbox with one language's toolchain.
# The caller binds the task's own directories by setting GRADE_BINDS (an array of extra bwrap arguments).
grade_exec() {
  local net=$1 snap=$2 home=$3 etc; shift 3
  etc=$(mktemp -d); etc_dir "$etc" grader 0 /grade-home
  base_args
  [ "$net" = nonet ] && A+=(--unshare-net)
  closure_binds "$STUDY_GRADE_CLOSURE"
  A+=(--ro-bind "$STUDY_GRADE/bin" /bin --ro-bind "$STUDY_GRADE/bin" /usr/bin --ro-bind "$etc" /etc
      --ro-bind-try "$STUDY_GRADE/etc/ssl" /etc/ssl --ro-bind "$snap" /study/snapshot --bind "$home" /grade-home
      --setenv HOME /grade-home --setenv PATH /bin --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
      --setenv DOTNET_CLI_TELEMETRY_OPTOUT 1 --setenv DOTNET_NOLOGO 1 --setenv TMPDIR /tmp)
  [ -d "$STUDY_GRADE/lib/openjdk" ] && A+=(--setenv JAVA_HOME "$STUDY_GRADE/lib/openjdk")
  [ "$net" = nonet ] || proxy_args
  A+=("${GRADE_BINDS[@]}")
  exec bwrap "${A[@]}" "$@"
}

# agent_exec <workspace> <home> <in-dir> <socket-dir> cmd...: the agent's sandbox. It has no network of its own (a
# private network namespace); HTTPS_PROXY points at a loopback forwarder to the egress socket in <socket-dir>, behind
# which harness/env/egress-conn.sh lets through only the hosts of harness/egress-allow.txt (the Anthropic API).
# Credentials come in as AGENT_ENV (an array of NAME=value); the cloud session's token file is bound if present.
agent_exec() {
  local ws=$1 home=$2 in=$3 sock=$4 etc kv; shift 4
  etc=$(mktemp -d); etc_dir "$etc" agent 0 /home/agent
  base_args
  A+=(--unshare-net)
  closure_binds "$STUDY_AGENT_CLOSURE"
  A+=(--ro-bind "$STUDY_AGENT/bin" /bin --ro-bind "$STUDY_AGENT/bin" /usr/bin --ro-bind "$STUDY_AGENT/lib" /lib --ro-bind "$etc" /etc
      --ro-bind "$STUDY_AGENT/etc/ssl" /etc/ssl --bind "$ws" /workspace --bind "$home" /home/agent
      --ro-bind "$in" /in --bind "$sock" /run/study --ro-bind-try /home/claude/.claude/remote /home/claude/.claude/remote
      --chdir /workspace --setenv HOME /home/agent --setenv USER agent --setenv PATH /bin --setenv LANG C.UTF-8
      --setenv TERM dumb --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
      --setenv HTTPS_PROXY http://127.0.0.1:3128 --setenv https_proxy http://127.0.0.1:3128
      --setenv HTTP_PROXY http://127.0.0.1:3128 --setenv http_proxy http://127.0.0.1:3128 --setenv NO_PROXY "")
  # Behind a TLS-re-signing egress proxy (a cloud session) the API's certificate chains to the proxy's CA.
  if [ -n "${HTTPS_PROXY:-}" ] && [ -f "${CURL_CA_BUNDLE:-}" ]; then
    A+=(--ro-bind "$CURL_CA_BUNDLE" /study-proxy-ca.crt --setenv NODE_EXTRA_CA_CERTS /study-proxy-ca.crt --setenv SSL_CERT_FILE /study-proxy-ca.crt)
  fi
  for kv in "${AGENT_ENV[@]}"; do A+=(--setenv "${kv%%=*}" "${kv#*=}"); done
  exec bwrap "${A[@]}" /bin/bash -c 'socat TCP-LISTEN:3128,bind=127.0.0.1,fork,reuseaddr UNIX-CONNECT:/run/study/egress.sock >/dev/null 2>&1 & sleep 0.3; exec "$@"' agent-wrapper "$@"
}
