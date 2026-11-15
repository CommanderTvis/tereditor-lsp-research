#!/bin/sh
# Dependencies for grading, resolved once with network: everything the gson module's build and tests need.
set -e
mvn -B -q -pl gson -am test
mvn -B -q -pl gson -am -DskipTests dependency:go-offline
