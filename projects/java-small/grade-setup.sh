#!/bin/sh
# Dependencies for grading, resolved once with network: everything the build and the tests need (surefire providers,
# the Quarkus test bootstrap, and the extension artifacts the integration-test modules' @QuarkusTest classes resolve at
# run time). Test failures are not fatal here; resolution and compile errors are.
set -e
mvn -B -q -Dmaven.test.failure.ignore=true -DskipSurefireTests=false test
mvn -B -q -DskipTests dependency:go-offline
