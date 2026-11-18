#!/bin/sh
# Dependencies for grading, resolved once with network: everything the gson and proto modules' builds and tests need.
set -e
mvn -B -q -pl gson,proto -am test
mvn -B -q -pl gson,proto -am -DskipTests dependency:go-offline
# The pull request google/gson#3061 adds protobuf-java-util as a test dependency of proto; grading is offline, so the
# artifact (and what it needs) is fetched here. A version the commit does not use is harmless.
mvn -B -q dependency:get -Dartifact=com.google.protobuf:protobuf-java-util:4.34.1 || true
