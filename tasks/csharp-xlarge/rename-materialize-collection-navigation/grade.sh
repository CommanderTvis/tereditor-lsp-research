#!/bin/sh
# Build and tests pass; the old type name is gone from every file and the new one exists, in the renamed file.
set -eu
sh /project/check.sh
[ ! -e src/EFCore/Query/MaterializeCollectionNavigationExpression.cs ] || { echo "old file still present"; exit 1; }
[ -e src/EFCore/Query/CollectionNavigationMaterializationExpression.cs ] || { echo "new file missing"; exit 1; }
if grep -rIlw --include='*.cs' --include='*.json' MaterializeCollectionNavigationExpression . | grep -q .; then echo "old name still present"; exit 1; fi
