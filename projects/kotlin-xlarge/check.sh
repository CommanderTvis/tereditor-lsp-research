#!/bin/sh
# DRAFT, never completed (project.toml, status = "skipped").
./gradlew --offline --no-daemon --console=plain :compiler:util:test > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
