#!/bin/sh
# Build passes and the test classes that use the renamed class pass (the whole provider suite is too slow to run per grading);
# the old name is gone from every text file and the new one exists, in the renamed file.
set -eu
TEST_FILTER="FullyQualifiedName~CompileTests" sh /project/check.sh
[ ! -e Source/LinqToDB/Linq/NoLinqCache.cs ] || { echo "old file still present"; exit 1; }
[ -e Source/LinqToDB/Linq/NoQueryCache.cs ] || { echo "new file missing"; exit 1; }
if grep -rIlw --include='*.cs' --include='*.txt' --include='*.md' NoLinqCache . | grep -q .; then echo "old name still present"; exit 1; fi
