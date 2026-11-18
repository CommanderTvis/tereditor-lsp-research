#!/bin/sh
# Build and tests pass; the old method name is gone from every C# file and the new one exists.
set -eu
sh /project/check.sh
if grep -rIlw --include='*.cs' GetSupportedImages . | grep -q .; then echo "old name GetSupportedImages is still present"; exit 1; fi
grep -rIlw --include='*.cs' GetAvailableImages . | grep -q . || { echo "new name GetAvailableImages not found"; exit 1; }
