#!/bin/sh
# DRAFT, never completed (project.toml, status = "skipped"): would resolve the Gradle build of a small module once.
set -e
./gradlew --no-daemon -q --console=plain :compiler:util:compileKotlin
