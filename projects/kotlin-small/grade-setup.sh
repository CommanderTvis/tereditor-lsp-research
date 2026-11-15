#!/bin/sh
# Dependencies for grading, resolved once with network: the wrapper, the JDK 8 toolchain and everything check.sh needs.
set -e
sh /project/check.sh online
