#!/bin/sh
# Old path and old hook names gone, new ones present, the scripts that load the hook use the new name, helpers kept;
# then the project check, and the hook is found and loaded by acme.sh's own lookup under the new name.
set -e
[ ! -e dnsapi/dns_ali.sh ] && [ -f dnsapi/dns_aliyun.sh ]
grep -qE '^dns_aliyun_add\(\) \{' dnsapi/dns_aliyun.sh
grep -qE '^dns_aliyun_rm\(\) \{' dnsapi/dns_aliyun.sh
grep -qE "^dns_aliyun_info=" dnsapi/dns_aliyun.sh
! grep -rnE '(^|[^A-Za-z0-9_])dns_ali(_add|_rm|_info)?([^A-Za-z0-9_]|$)' acme.sh dnsapi deploy notify
for h in _prepare_ali_credentials _ali_rest _ali_urlencode_upper _ali_nonce _ali_timestamp; do grep -qE "^$h\(\) \{" dnsapi/dns_aliyun.sh; done
for f in deploy/ali_cdn.sh deploy/ali_dcdn.sh; do grep -qE '_findHook .*[ "]dns_aliyun["]?\)' "$f"; done
sh /project/check.sh
export LE_WORKING_DIR="$PWD" LE_CONFIG_HOME=/tmp/acme-home
cat > /tmp/load.sh <<'SH'
h="$(_findHook example.com "$_SUB_FOLDER_DNSAPI" dns_aliyun)"; [ -n "$h" ] || exit 1
. "$h" || exit 1
_exists dns_aliyun_add && _exists dns_aliyun_rm && _exists _prepare_ali_credentials || exit 1
[ -z "$(_findHook example.com "$_SUB_FOLDER_DNSAPI" dns_ali)" ] || exit 1
echo loaded
SH
sh acme.sh . /tmp/load.sh | grep -qx loaded
