#!/bin/sh
# The Iterable function is renamed in kotlin-result (code, tests, deprecation hints) and the example and benchmarks;
# the Flow function of the same name in kotlin-result-coroutines keeps its name; then everything builds and the tests,
# with the hidden ones, pass.
if grep -rnw --include=*.kt --include=*.kts filterErr kotlin-result example benchmarks; then
  echo "grade: the old name is still used"; exit 1
fi
grep -q 'fun <V, E> Flow<Result<V, E>>\.filterErr()' \
  kotlin-result-coroutines/src/commonMain/kotlin/com/github/michaelbull/result/coroutines/flow/Flow.kt \
  || { echo "grade: Flow.filterErr was renamed"; exit 1; }
sh /project/check.sh
