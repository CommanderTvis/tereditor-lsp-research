#!/bin/sh
# Compiles and tests the modules whose tests run in the sandbox without native libraries or services, offline: the
# core modules (support, pactbroker, model, matchers) and the consumer and provider base modules. TEST_FILTER, lines
# "<gradle-project-path> <test-class>" (the fail-to-pass test classes of a mined task), restricts the run to them.
off=--offline; [ "${1:-}" = online ] && off=
export GITHUB_WORKFLOW=study
if [ -n "${TEST_FILTER:-}" ]; then
  tasks=$(printf '%s\n' "$TEST_FILTER" | awk 'NF==2 {if ($1!=p) {printf " %s:test", $1; p=$1}; printf " --tests %s", $2}')
else
  tasks=":core:support:test :core:pactbroker:test :core:model:test :core:matchers:test :consumer:test :provider:test"
fi
./gradlew --no-daemon $off -q --no-configuration-cache --init-script /project/grade-exclude.gradle -Pkotlin.compiler.execution.strategy=in-process --continue \
  $tasks > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
