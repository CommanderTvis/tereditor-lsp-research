#!/bin/sh
# Dependencies for grading, resolved once with network: wrapper, build logic and what :logging needs to compile and run
# tests. Compile errors are fatal; test failures are not.
# Gradle's own build asks for a JDK 25 daemon toolchain (gradle/gradle-daemon-jvm.properties); the environment's default
# is JDK 21, so point Gradle at the JDK 25 home (study-jdk25) for this project only, without auto-download.
export JAVA_HOME=$(study-jdk25)
JDK17=$(study-jdk17); JDK11=$(study-jdk11); JDK8=$(study-jdk8)
export JDK_1_8=$JDK8 JDK_8_0=$JDK8 JDK_11_0=$JDK11 JDK_17_0=$JDK17 JDK_25_0=$JAVA_HOME
export GF="--no-configuration-cache -Dorg.gradle.isolated-projects=false -Dorg.gradle.java.installations.paths=$JAVA_HOME,$JDK17,$JDK11,$JDK8 -Dorg.gradle.java.installations.auto-download=false"
t=$(date +%s)
./gradlew $GF --no-daemon --console=plain :logging:compileTestGroovy > /tmp/gradle-setup.log 2>&1
rc=$?
tail -30 /tmp/gradle-setup.log
echo "grade-setup compile of :logging tests: rc=$rc $(( $(date +%s) - t )) s" >&2
[ $rc = 0 ] || exit $rc
t=$(date +%s)
./gradlew $GF --no-daemon --console=plain :logging:test --tests 'org.gradle.internal.logging.console.ProgressBarTest' > /tmp/gradle-setup2.log 2>&1
rc=$?
tail -20 /tmp/gradle-setup2.log
echo "grade-setup first :logging test: rc=$rc $(( $(date +%s) - t )) s" >&2
exit 0
