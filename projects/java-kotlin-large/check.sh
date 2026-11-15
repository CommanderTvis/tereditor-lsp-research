#!/bin/sh
set -e
online=
[ "${1:-}" = online ] && online=1
args="--no-daemon --no-configuration-cache"
[ -z "$online" ] && args="$args --offline"
./gradlew $args -q test > gradle-study.log 2>&1
rc=$?
tail -80 gradle-study.log
exit $rc
