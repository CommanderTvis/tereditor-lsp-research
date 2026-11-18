#!/bin/sh
# Grading dependencies, fetched once with network: the repository's yarn workspaces (yarn 4 from .yarn/releases, as the
# repository pins it) installed into node_modules/ with every install script skipped, then the packages that the Sass
# sources and the Jest tests of @carbon/styles need generated files from (tokens, themes, inlined grid) and the React components (icons, utilities), built with the
# repository's own lerna. Everything it produces is git-ignored, so it becomes the grading overlay. The reference
# compilation of the unmodified tree (compile.sh) is stored in node_modules/.study-ref for check.sh.
set -e
yarn=$PWD/$(ls .yarn/releases/yarn-*.cjs | head -n1)
mkdir -p /tmp/study-bin; printf '#!/bin/sh\nexec node "%s" "$@"\n' "$yarn" > /tmp/study-bin/yarn; chmod +x /tmp/study-bin/yarn
export PATH=/tmp/study-bin:$PATH YARN_ENABLE_TELEMETRY=0 YARN_ENABLE_PROGRESS_BARS=0 HUSKY=0 CI=1 NX_DAEMON=false NX_NO_CLOUD=true
yarn install --immutable --mode=skip-build
node_modules/.bin/lerna run build --concurrency 3 \
  --scope @carbon/colors --scope @carbon/layout --scope @carbon/type --scope @carbon/motion --scope @carbon/themes \
  --scope @carbon/grid --scope @carbon/feature-flags \
  --scope @carbon/icons-react --scope @carbon/utilities --scope @carbon/utilities-react --scope @carbon/icon-helpers \
  --include-dependencies
sh /project/compile.sh /tmp/study-ref
rm -rf node_modules/.study-ref; mkdir -p node_modules/.study-ref; cp -a /tmp/study-ref/. node_modules/.study-ref/; rm -f node_modules/.study-ref/.entries
