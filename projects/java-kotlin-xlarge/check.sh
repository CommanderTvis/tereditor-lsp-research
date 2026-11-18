#!/bin/sh
# Build and test offline.
#   check.sh f2p FILE      FILE holds lines "<project path> <test class>", e.g. ":logging org.gradle.internal.logging.console.ProgressBarTest"
#   check.sh tasks T...    raw Gradle tasks, e.g. :process-services-base:java9Test
#   check.sh modules P...  every test of the given project paths (pass-to-pass)
# Gradle's own build asks for a JDK 25 daemon toolchain (gradle/gradle-daemon-jvm.properties); the environment's default
# is JDK 21, so point Gradle at the JDK 25 home (study-jdk25) for this project only, without auto-download.
export JAVA_HOME=$(study-jdk25)
JDK17=$(study-jdk17); JDK11=$(study-jdk11); JDK8=$(study-jdk8)
export JDK_1_8=$JDK8 JDK_8_0=$JDK8 JDK_11_0=$JDK11 JDK_17_0=$JDK17 JDK_25_0=$JAVA_HOME
export GF="--no-configuration-cache -Dorg.gradle.isolated-projects=false -Dorg.gradle.java.installations.paths=$JAVA_HOME,$JDK17,$JDK11,$JDK8 -Dorg.gradle.java.installations.auto-download=false"
mode=$1; shift
args=""
case "$mode" in
  f2p)
    for m in $(awk '{print $1}' "$1" | sort -u); do
      args="$args $m:test"
      for c in $(awk -v m="$m" '$1==m {print $2}' "$1"); do args="$args --tests $c"; done
    done ;;
  modules) for m in "$@"; do args="$args $m:test"; done ;;
  tasks) args="$*" ;;
esac
./gradlew $GF --offline --no-daemon --console=plain $args > /tmp/gradle.log 2>&1
rc=$?
tail -60 /tmp/gradle.log
exit $rc
