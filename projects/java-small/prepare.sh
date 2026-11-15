#!/bin/sh
# Server side, with network: resolve the Maven build once into /cache/home/.m2 so the IntelliJ import finds it.
set -e
mvn -B -q -DskipTests dependency:go-offline
