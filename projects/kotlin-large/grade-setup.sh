#!/bin/sh
# Dependencies for grading, resolved once with network: the wrapper, the build logic, every JVM module compiled (main
# and test; the outputs stay in the grade home's Gradle build cache, so grading recompiles only what a patch affects)
# and the test runtime of every JVM module resolved.
set -e
sh /project/check.sh online
