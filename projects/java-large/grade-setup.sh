#!/bin/sh
# Dependencies for grading, resolved once with network: everything the build and the tests need (surefire providers
# included). Test failures are not fatal here; resolution and compile errors are.
set -e
mvn -B -q -Dmaven.test.failure.ignore=true test
mvn -B -q -DskipTests dependency:go-offline
