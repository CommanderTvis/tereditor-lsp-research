#!/bin/sh
# Dependencies for grading, resolved once with network: the wrapper, buildSrc's plugins and everything check.sh needs.
set -e
sh /project/check.sh online
