#!/bin/sh
# Server side, with network: resolve the Gradle build once into /cache/home/.gradle (wrapper distribution, build logic
# and the dependencies of a small subproject) so the IntelliJ and Kotlin import find them.
# Gradle's own build asks for a JDK 25 daemon toolchain (gradle/gradle-daemon-jvm.properties); the environment's default
# is JDK 21, so point Gradle at the JDK 25 home (study-jdk25) for this project only, without auto-download.
export JAVA_HOME=$(study-jdk25)
JDK17=$(study-jdk17); JDK11=$(study-jdk11); JDK8=$(study-jdk8)
export JDK_1_8=$JDK8 JDK_8_0=$JDK8 JDK_11_0=$JDK11 JDK_17_0=$JDK17 JDK_25_0=$JAVA_HOME
export GF="--no-configuration-cache -Dorg.gradle.isolated-projects=false -Dorg.gradle.java.installations.paths=$JAVA_HOME,$JDK17,$JDK11,$JDK8 -Dorg.gradle.java.installations.auto-download=false"
t=$(date +%s)
for try in 1 2 3 4; do
  if ./gradlew $GF --no-daemon -q --console=plain :logging:compileJava > /tmp/prep.log 2>&1; then break; fi
  tail -30 /tmp/prep.log
  [ "$try" -lt 4 ] || exit 1
  echo "prepare: attempt $try failed (shared Gradle home busy?); retrying in 120 s" >&2; sleep 120
done
echo "prepare: $(( $(date +%s) - t )) s" >&2
