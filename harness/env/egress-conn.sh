#!/bin/bash
# egress-conn.sh <log>: one connection from the agent's egress socket (socat runs this per connection). The agent's
# sandbox has no network of its own; its HTTPS_PROXY reaches this through a unix socket. Only "CONNECT host:443" to a
# host listed in harness/egress-allow.txt is let through; everything else gets 403 and is logged (the log is kept with
# the run, and a run that tried anything else is flagged by analysis/extract.py).
set -u
log=$1
deny() { printf 'HTTP/1.1 403 Forbidden\r\nContent-Length: 0\r\nConnection: close\r\n\r\n'; echo "$(date -u +%FT%TZ) DENY $1" >> "$log"; exit 0; }
IFS= read -r -t 10 line || exit 0
line=${line%$'\r'}
while IFS= read -r -t 10 h; do h=${h%$'\r'}; [ -z "$h" ] && break; done
case "$line" in "CONNECT "*" HTTP/1."?) ;; *) deny "not-connect: ${line:0:80}" ;; esac
target=${line#CONNECT }; target=${target%% *}
host=${target%:*}; port=${target##*:}
[[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] || deny "bad-host: ${target:0:80}"
[ "$port" = 443 ] || deny "port: $target"
grep -qixF -- "$host" <(grep -v '^#' "$STUDY_ROOT/harness/egress-allow.txt") || deny "host: $target"
echo "$(date -u +%FT%TZ) ALLOW $target" >> "$log"
printf 'HTTP/1.1 200 Connection established\r\n\r\n'
if [ -n "${HTTPS_PROXY:-}" ]; then   # a cloud session reaches the internet only through its own proxy
  u=${HTTPS_PROXY#*://}; auth=; case "$u" in *@*) auth=${u%@*}; u=${u##*@} ;; esac; u=${u%%/*}
  exec socat - "PROXY:${u%:*}:$host:443,proxyport=${u##*:}${auth:+,proxyauth=$auth}"
fi
exec socat - "TCP:$host:443,connect-timeout=15"
