#!/bin/sh
# Server side, with network: resolve the Maven build once into /cache/home/.m2 so the IntelliJ import finds it: the
# project's dependencies and every plugin of the test lifecycle. Build outputs are removed again (git-ignored anyway).
set -e
mvn -B -q -DskipTests dependency:go-offline
mvn -B -q -DskipTests test-compile
find . -name target -type d -prune -exec rm -rf {} +
