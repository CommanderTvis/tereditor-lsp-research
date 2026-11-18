#!/bin/sh
# Server side, with network: resolve the Gradle build once into /cache/home/.gradle (wrapper distribution and the
# dependencies of the core, analysis and test-framework modules) so the IntelliJ import finds them. Build outputs are
# git-ignored by the project (build/, .gradle/).
# Lucene main needs JDK 25 to 27 (the default JDK 21 is refused by its build); 10.6.0 builds with it too.
export JAVA_HOME=$(study-jdk25)
t=$(date +%s)
# /cache/home/.gradle is shared with the other projects' imports: when another Gradle holds its journal lock, retry.
for try in 1 2 3 4 5 6 7 8 9 10; do
  if ./gradlew --no-daemon -q --console=plain :lucene:core:dependencies :lucene:test-framework:dependencies > /dev/null &&
     ./gradlew --no-daemon -q --console=plain :lucene:core:compileJava :lucene:test-framework:compileJava; then break; fi
  [ "$try" -lt 10 ] || exit 1
  echo "prepare: attempt $try failed (shared Gradle home busy?); retrying in 120 s" >&2; sleep 120
done
echo "prepare: $(( $(date +%s) - t )) s" >&2
