#!/bin/sh
# Build-and-test for acme.sh. The project has no test suite in its tree (its CI runs against live ACME servers), so
# the check is: every script parses (sh -n, as the hooks are sourced by acme.sh), and acme.sh starts, prints its
# version and help, and still defines every command function its option parser dispatches to. Tasks add their own
# checks in grade.sh.
set -e
for f in acme.sh dnsapi/*.sh deploy/*.sh notify/*.sh; do
  sh -n "$f" || { echo "check: $f does not parse"; exit 1; }
done
export LE_WORKING_DIR=/tmp/acme-home LE_CONFIG_HOME=/tmp/acme-home; mkdir -p /tmp/acme-home
sh acme.sh --version | grep -q 'acme.sh'
sh acme.sh --help | grep -q -- '--issue'
for c in install uninstall upgrade issue deploy signcsr showcsr installcert renew renewAll revoke remove deactivate \
         registeraccount updateaccount deactivateaccount list info installcronjob uninstallcronjob cron toPkcs \
         toPkcs8 createAccountKey createDomainKey createCSR setnotify setdefaultca setdefaultchain; do
  grep -qE "^$c\(\) \{" acme.sh || { echo "check: command function $c is missing"; exit 1; }
done
echo "check: ok"
