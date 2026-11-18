#!/bin/sh
# Server side, with network: resolve the Maven build once into /cache/home/.m2 so the language servers' import finds it: the parent
# pom embabel-build-parent (hosted on repo.embabel.com/artifactory, reached here), the dependencies and plugins of every module
# (a full compile of main and test code of the reactor). Build outputs are removed again (git-ignored anyway).
set -e
export SKIP_TESTCONTAINER_TESTS=true MAVEN_OPTS=-Xmx2g
mvn -B -q -DskipTests test-compile
find . -name target -type d -prune -exec rm -rf {} +
