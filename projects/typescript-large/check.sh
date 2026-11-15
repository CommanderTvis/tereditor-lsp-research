#!/bin/sh
# Build-and-test for typeorm at the commit being graded, offline, on sql.js only (no database servers exist here):
# compile the library and its tests with tsc (as `npm test` does), then mocha on the unit tests, or on the compiled
# test files or directories given as arguments (paths under test/, without extension; a task's grade.sh passes the
# affected tests). The test connection configuration (ormconfig.json, git-ignored upstream) lists only sqljs.
set -e
if [ -d packages/typeorm ]; then cd packages/typeorm; fi
printf '[{"skip": false, "name": "sqljs", "type": "sqljs", "logging": false}]\n' > ormconfig.json
rm -rf build
npx tsc
[ $# -gt 0 ] || set -- test/unit
specs=""
for t in "$@"; do
  if [ -d "build/compiled/$t" ]; then specs="$specs build/compiled/$t"; else specs="$specs build/compiled/$t.js"; fi
done
npx mocha --no-config --file ./build/compiled/test/utils/test-setup.js --exit --recursive --timeout 90000 $specs
