#!/bin/sh
# Old name gone everywhere, new one defined once and called at every former call site, neighbours untouched, then
# the project check; the renamed helper still prints the time when called through acme.sh.
set -e
files="acme.sh $(ls dnsapi/*.sh deploy/*.sh notify/*.sh)"
! grep -nE '(^|[^A-Za-z0-9_$])_time([^A-Za-z0-9_]|$)' $files
[ "$(grep -cE '^_unix_time\(\) \{' acme.sh)" -eq 1 ]
[ "$(cat $files | grep -oE '(^|[^A-Za-z0-9_$])_unix_time([^A-Za-z0-9_]|$)' | wc -l)" -eq 34 ]
grep -qE '^_time2str\(\) \{' acme.sh
[ "$(grep -cE '^_timeweb_[a-z_]+\(\) \{' dnsapi/dns_timeweb.sh)" -eq 11 ]
grep -q '_end_time="$(_unix_time)"' acme.sh
sh /project/check.sh
export LE_WORKING_DIR=/tmp/acme-home LE_CONFIG_HOME=/tmp/acme-home
sh acme.sh _unix_time | grep -qE '^[0-9]{9,}$'
