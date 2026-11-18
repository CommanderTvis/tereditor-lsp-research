#!/bin/sh
# Dependencies for grading, resolved once with network: the parent pom from the Embabel artifactory, the dependencies and plugins of
# every module (a full compile of main and test code of the reactor), and the surefire providers (a test run of the api module;
# test failures are not fatal here, resolution and compile errors are).
set -e
export SKIP_TESTCONTAINER_TESTS=true MAVEN_OPTS=-Xmx2g
mvn -B -q -DskipTests test-compile
mvn -B -q -pl embabel-agent-api -am -Dmaven.test.failure.ignore=true test -Dtest='GoapPlannerTest' -Dsurefire.failIfNoSpecifiedTests=false
