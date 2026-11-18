#!/bin/sh
# DRAFT, never completed: the build does not start in the current grading environment (project.toml, status = "skipped").
# Cold build of a small module of the Kotlin compiler repository, bounded at 20 minutes.
t=$(date +%s)
timeout 1200 ./gradlew --no-daemon --console=plain :compiler:util:compileKotlin > /tmp/gradle-setup.log 2>&1
rc=$?
tail -30 /tmp/gradle-setup.log
echo "grade-setup cold compile of :compiler:util: rc=$rc $(( $(date +%s) - t )) s" >&2
exit $rc
