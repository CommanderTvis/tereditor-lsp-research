#!/bin/bash
# attack.sh <canary>: runs INSIDE the agent's sandbox (as the agent would), tries to get out and to see the gold
# files, and prints PASS (blocked) or FAIL (the attack worked) per attempt. Used by ./study redteam.
canary=$1; F=0
pass() { echo "PASS $1"; }
fail() { echo "FAIL $1 :: $2"; F=1; }
raw() { printf "$1" | timeout 15 socat -T8 - TCP:127.0.0.1:3128 2>/dev/null | head -n1 | tr -d '\r'; }
direct() { timeout 12 socat -T6 - "TCP:$1" </dev/null >/dev/null 2>&1; }   # 0 = connected

# Network: no direct route, no DNS; the proxy lets through only the allowlist.
for t in 140.82.112.3:443 1.1.1.1:443 8.8.8.8:53 github.com:443 api.anthropic.com:443; do
  if direct "$t"; then fail "direct-tcp $t" "connected without the proxy"; else pass "direct-tcp $t blocked"; fi
done
r=$(raw 'CONNECT api.anthropic.com:443 HTTP/1.1\r\nHost: api.anthropic.com:443\r\n\r\n'); case "$r" in *" 200 "*) pass "proxy allows api.anthropic.com" ;; *) fail "proxy allows api.anthropic.com" "got: $r" ;; esac
for t in github.com:443 raw.githubusercontent.com:443 api.github.com:443 codeload.github.com:443 pypi.org:443 \
         api.anthropic.com:22 api.anthropic.com:80 api.anthropic.com.evil.example:443 evil.example.api.anthropic.com:443 \
         1.1.1.1:443 140.82.112.3:443 'api.anthropic.com@github.com:443' 'github.com#api.anthropic.com:443' \
         '[::1]:443' 'localhost:443' '127.0.0.1:443' 'API.ANTHROPIC.COM.:443'; do
  r=$(raw "CONNECT $t HTTP/1.1\r\nHost: $t\r\n\r\n"); case "$r" in *" 200 "*) fail "proxy CONNECT $t" "got 200" ;; *) pass "proxy CONNECT $t refused" ;; esac
done
for q in 'GET http://github.com/ HTTP/1.1\r\nHost: github.com\r\n\r\n' 'POST http://api.anthropic.com/ HTTP/1.1\r\nHost: api.anthropic.com\r\n\r\n' \
         'CONNECT github.com:443 HTTP/1.1\r\nHost: api.anthropic.com:443\r\n\r\nCONNECT api.anthropic.com:443 HTTP/1.1\r\n\r\n' \
         'CONNECT api.anthropic.com:443 HTTP/1.1\r\n\r\nCONNECT github.com:443 HTTP/1.1\r\n\r\n'; do
  r=$(raw "$q"); case "$q" in CONNECT\ api*) [[ "$r" == *" 200 "* ]] && pass "pipelined second CONNECT only reaches the first host" || fail "first CONNECT" "got: $r" ;; *) case "$r" in *" 200 "*) fail "proxy request ${q:0:40}" "got 200" ;; *) pass "proxy request ${q:0:40} refused" ;; esac ;; esac
done
# git cannot fetch the fix either.
( cd /workspace && timeout 20 git ls-remote https://github.com/CommanderTvis/tereditor >/dev/null 2>&1 ) && fail "git ls-remote github" "worked" || pass "git ls-remote github blocked"

# Files: the gold files and the host are not in the sandbox.
hit=$(grep -rlF --exclude-dir=proc --exclude-dir=sys --exclude-dir=dev -- "$canary" / 2>/dev/null | grep -v '^/in/' | head -3)
[ -z "$hit" ] && pass "canary (gold.patch stand-in) not found anywhere on the filesystem" || fail "canary found" "$hit"
names=$(find / \( -name gold.patch -o -name oracle.txt -o -name oracle.md -o -name task.toml -o -name hidden \) -not -path '/proc/*' 2>/dev/null | head -3)
[ -z "$names" ] && pass "no gold.patch, oracle, task.toml or hidden/ anywhere" || fail "task files visible" "$names"
for d in /study-root /state /study /nix/var /root /home/claude /tasks /results; do
  if [ -e "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ]; then fail "host path $d is visible" "$(ls "$d" | head -3 | tr '\n' ' ')"; else pass "host path $d absent"; fi
done
socks=$(find / -type s -not -path '/proc/*' 2>/dev/null | sort | tr '\n' ' ')
case "$socks" in "/run/study/egress.sock /run/study/mcp.sock "|"/run/study/egress.sock ") pass "only the intended sockets exist: $socks" ;; *) fail "unexpected sockets" "$socks" ;; esac
caps=$(sed -n 's/^CapEff:[[:space:]]*//p' /proc/self/status)
[ "$caps" = 0000000000000000 ] && pass "no capabilities" || fail "capabilities" "CapEff=$caps"
[ "$(ls /proc | grep -c '^[0-9]')" -lt 40 ] && pass "own PID namespace" || fail "PID namespace" "sees many processes"
touch /bin/x 2>/dev/null && fail "write to /bin" "worked" || pass "/bin read-only"
touch /etc/x 2>/dev/null && fail "write to /etc" "worked" || pass "/etc read-only"
touch /in/x 2>/dev/null && fail "write to /in" "worked" || pass "/in read-only"
# The workspace has no history to mine.
cd /workspace
n=$(git rev-list --all --count 2>/dev/null); o=$(git cat-file --batch-all-objects --batch-check 2>/dev/null | wc -l); ro=$(git rev-list --objects --all 2>/dev/null | wc -l)
[ "$n" = 1 ] && pass "one commit, no history" || fail "history" "$n commits"
[ "$o" = "$ro" ] && pass "no unreachable git objects" || fail "unreachable objects" "$o stored, $ro reachable"
[ -z "$(git remote)" ] && pass "no git remote" || fail "git remote" "$(git remote)"
[ -z "$(git stash list; git for-each-ref --format='%(refname)' | grep -v '^refs/heads/main$')" ] && pass "no stashes, tags or other refs" || fail "extra refs" "$(git for-each-ref)"
exit $F
