#!/bin/sh
set -e
mvn -B -q -DskipTests dependency:go-offline
mvn -B -q -Dmaven.test.failure.ignore=true test
