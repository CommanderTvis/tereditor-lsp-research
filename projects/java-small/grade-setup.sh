#!/bin/sh
# Dependencies for grading, resolved once with network: everything the build and the tests need. Test failures are not
# fatal here (six tests fail on JDK 21 at the pin, see check.sh); resolution and compile errors are.
set -e
. /project/pom-jdk21.sh
mvn -B -q -Dmaven.test.failure.ignore=true test
mvn -B -q -DskipTests dependency:go-offline
