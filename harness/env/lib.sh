# Sourced by the harness scripts (bash). The three sandboxes of a run, built with bubblewrap from Nix closures:
#   agent   only the agent closure (core utilities, git, ripgrep, jq, socat, Claude Code); no compiler exists in it
#   server  the server's FHS-shaped root, tereditor and its runtime cache; the agent reaches it only through a socket
#   grade   one language's toolchain, the project and the task, no network
# Every sandbox gets its own user, PID, IPC and UTS namespaces, a private /tmp and an empty environment.

log() { echo "[env $(date -u +%H:%M:%S)] $*" >&2; }
die() { echo "env: $*" >&2; exit 2; }

TEREDITOR_COMMIT=$(sed -n 's/^TEREDITOR_COMMIT=//p' "$STUDY_ROOT/harness/tereditor.env")
TEREDITOR_DIR="$STUDY_STATE/tereditor/$TEREDITOR_COMMIT-$(uname -m)"
CACHE="$STUDY_STATE/cache"
mkdir -p "$CACHE/home" "$CACHE/managed" "$CACHE/state"
# Extra environment (NAME=value) and binds a caller adds to a sandbox.
SERVER_ENV=(); AGENT_ENV=(); GRADE_BINDS=()

# Arguments accumulate in the array A; each sandbox function ends with `exec bwrap "${A[@]}" cmd...`.
closure_binds() { local p; while IFS= read -r p; do A+=(--ro-bind "$p" "$p"); done < "$1"; }

# etc_dir <dir> <user> <uid> <home>: a minimal /etc for a sandbox.
etc_dir() {
  mkdir -p "$1"
  printf 'root:x:0:0:root:/root:/bin/sh\n%s:x:%s:%s:%s:%s:/bin/bash\n' "$2" "$3" "$3" "$2" "$4" > "$1/passwd"
  printf 'root:x:0:\n%s:x:%s:\n' "$2" "$3" > "$1/group"
  printf '127.0.0.1 localhost\n::1 localhost\n' > "$1/hosts"
  cp /etc/resolv.conf "$1/resolv.conf" 2>/dev/null || printf 'nameserver 1.1.1.1\n' > "$1/resolv.conf"
  printf 'hosts: files dns\npasswd: files\ngroup: files\n' > "$1/nsswitch.conf"
}

base_args() { # <uid>
  A=(--unshare-user --unshare-ipc --unshare-uts --unshare-pid --die-with-parent --uid "$1" --gid "$1"
     --proc /proc --dev /dev --tmpfs /tmp --clearenv)
}

# server_exec <mode> <workspace> <lsplog-dir> <license-dir> [cmd...]: the language server's sandbox, as uid 1000.
# Without a command it serves MCP on stdin and stdout (harness/server/serve.sh).
server_exec() {
  local mode=$1 ws=$2 lsplog=$3 licdir=$4 intellij=0 etc; shift 4
  [ -x "$TEREDITOR_DIR/tereditor-headless" ] || die "tereditor is not built ($TEREDITOR_DIR): run ./study setup"
  case "$mode" in intellij-*) intellij=1; mode=${mode#intellij-} ;; esac
  etc=$STUDY_STATE/etc-server; [ -f "$etc/passwd" ] || etc_dir "$etc" tereditor 1000 /cache/home
  base_args 1000
  closure_binds "$STUDY_SERVER_CLOSURE"
  [ -n "${STUDY_JVM_CLOSURE:-}" ] && closure_binds "$STUDY_JVM_CLOSURE"
  A+=(--ro-bind "$STUDY_SERVER_FHS/bin" /bin --ro-bind "$STUDY_SERVER_FHS/bin" /usr/bin
      --ro-bind "$STUDY_SERVER_FHS/lib" /lib --ro-bind "$STUDY_SERVER_FHS/lib" /lib64 --ro-bind "$STUDY_SERVER_FHS/lib" /usr/lib
      --ro-bind "$etc" /etc --ro-bind "$STUDY_SERVER_FHS/etc/ssl" /etc/ssl
      --ro-bind "$TEREDITOR_DIR" /opt/tereditor --bind "$CACHE" /cache --bind "$ws" /workspace
      --bind "$lsplog" /study/lsplog --ro-bind "$licdir" /study/license --ro-bind "$STUDY_ROOT/harness/server" /study/harness
      --chdir /workspace --setenv HOME /cache/home --setenv PATH "/bin${STUDY_JVM:+:$STUDY_JVM/bin}"
      --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt --setenv TEREDITOR_MODE "$mode" --setenv TEREDITOR_INTELLIJ "$intellij")
  [ -n "${STUDY_JVM:-}" ] && A+=(--setenv JAVA_HOME "$STUDY_JVM/lib/openjdk")
  local kv; for kv in "${SERVER_ENV[@]}"; do A+=(--setenv "${kv%%=*}" "${kv#*=}"); done
  [ $# -gt 0 ] || set -- /bin/sh /study/harness/serve.sh
  exec bwrap "${A[@]}" "$@"
}

# grade_exec <net|nonet> <snapshot> <grade-home> cmd...: the grader's sandbox with one language's toolchain.
# The caller binds the task's own directories by setting GRADE_BINDS (an array of extra bwrap arguments).
grade_exec() {
  local net=$1 snap=$2 home=$3 etc; shift 3
  etc=$STUDY_STATE/etc-grade; [ -f "$etc/passwd" ] || etc_dir "$etc" grader 0 /grade-home
  base_args 0
  [ "$net" = nonet ] && A+=(--unshare-net)
  closure_binds "$STUDY_GRADE_CLOSURE"
  A+=(--ro-bind "$STUDY_GRADE/bin" /bin --ro-bind "$STUDY_GRADE/bin" /usr/bin --ro-bind "$etc" /etc
      --ro-bind-try "$STUDY_GRADE/etc/ssl" /etc/ssl --ro-bind "$snap" /study/snapshot --bind "$home" /grade-home
      --setenv HOME /grade-home --setenv PATH /bin --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
      --setenv DOTNET_CLI_TELEMETRY_OPTOUT 1 --setenv DOTNET_NOLOGO 1 --setenv TMPDIR /tmp)
  [ -d "$STUDY_GRADE/lib/openjdk" ] && A+=(--setenv JAVA_HOME "$STUDY_GRADE/lib/openjdk")
  A+=("${GRADE_BINDS[@]}")
  exec bwrap "${A[@]}" "$@"
}

# agent_exec <workspace> <home> <in-dir> <socket-dir> cmd...: the agent's sandbox, as uid 1001, network on (the API).
# Credentials come in as AGENT_ENV (an array of NAME=value); the cloud session's token file is bound if present.
agent_exec() {
  local ws=$1 home=$2 in=$3 sock=$4 etc kv; shift 4
  etc=$STUDY_STATE/etc-agent; [ -f "$etc/passwd" ] || etc_dir "$etc" agent 1001 /home/agent
  base_args 1001
  closure_binds "$STUDY_AGENT_CLOSURE"
  A+=(--ro-bind "$STUDY_AGENT/bin" /bin --ro-bind "$STUDY_AGENT/bin" /usr/bin --ro-bind "$etc" /etc
      --ro-bind "$STUDY_AGENT/etc/ssl" /etc/ssl --bind "$ws" /workspace --bind "$home" /home/agent
      --ro-bind "$in" /in --bind "$sock" /run/study --ro-bind-try /home/claude/.claude/remote /home/claude/.claude/remote
      --chdir /workspace --setenv HOME /home/agent --setenv USER agent --setenv PATH /bin --setenv LANG C.UTF-8
      --setenv TERM dumb --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt)
  for kv in "${AGENT_ENV[@]}"; do A+=(--setenv "${kv%%=*}" "${kv#*=}"); done
  exec bwrap "${A[@]}" "$@"
}
