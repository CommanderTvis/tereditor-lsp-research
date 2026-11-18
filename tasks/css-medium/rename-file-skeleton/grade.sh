#!/bin/sh
# The partial is at the new path only, no module path points at the old one, the mirrors forward to the new one, then the
# held-out tests (the updated skeleton-test.js and the @carbon/styles entry-point tests, with the snapshot) and the compile check.
set -e
[ ! -e packages/styles/scss/utilities/_skeleton.scss ] && [ -f packages/styles/scss/utilities/_skeleton-animation.scss ]
g() { grep -r --include='*.scss' --exclude-dir=node_modules --exclude-dir=.nx "$@" packages; }
! g -nE "utilities/skeleton(['\"]|/)"
grep -q "^@forward 'skeleton-animation';" packages/styles/scss/utilities/_index.scss
[ "$(g -lE "utilities/skeleton-animation'" | wc -l)" -ge 38 ]
for m in react carbon-components carbon-components-react; do
  grep -q "@forward '@carbon/styles/scss/utilities/skeleton-animation';" "packages/$m/scss/utilities/_skeleton.scss"
done
! grep -q 'utilities/_skeleton\.scss' packages/styles/files.js
export HOME="${HOME:-/tmp}" BABEL_ENV=test
node_modules/.bin/jest --ci packages/styles/scss/utilities/__tests__/skeleton-test.js packages/styles/__tests__/styles-test.js
sh /project/check.sh
