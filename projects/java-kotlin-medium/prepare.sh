#!/bin/sh
set -e
mvn -B -q -DskipTests dependency:go-offline
