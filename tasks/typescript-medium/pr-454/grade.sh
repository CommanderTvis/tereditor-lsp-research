#!/bin/sh
# Fail to pass: the cases of src/middleware/etag/index.test.ts and src/utils/crypto.test.ts that the pull request
# changed. Pass to pass: the rest of those files and src/utils/body.test.ts (the affected modules).
set -e
sh /project/check.sh src/middleware/etag/index.test.ts src/utils/crypto.test.ts src/utils/body.test.ts
