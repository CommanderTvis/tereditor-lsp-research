#!/bin/sh
set -eu
[ -f /project/check.sh ] && sh /project/check.sh "$@" || true
