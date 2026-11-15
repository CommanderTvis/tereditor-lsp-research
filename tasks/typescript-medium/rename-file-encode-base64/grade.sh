#!/bin/sh
# The module and its test live under the new names only, nothing imports the old path, jsr.json points at the new
# file; then the type check and the tests (including the hidden test, which imports ./base64).
set -e
[ ! -e src/utils/encode.ts ]
[ ! -e src/utils/encode.test.ts ]
[ -f src/utils/base64.ts ]
[ -f src/utils/base64.test.ts ]
if grep -rnE "from '[^']*/encode'" src; then exit 1; fi
if grep -n 'utils/encode' jsr.json; then exit 1; fi
grep -q '"./utils/base64": "./src/utils/base64.ts"' jsr.json
sh /project/check.sh
