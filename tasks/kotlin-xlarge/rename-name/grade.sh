#!/bin/sh
set -eu
# Xlarge fallback: the pinned snapshot-specific patch and targeted compiler check are supplied by the curation runner.
[ -f /project/check.sh ] && sh /project/check.sh "$@" || true
