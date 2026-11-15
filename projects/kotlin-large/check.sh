#!/bin/sh
# check.sh [online] [gradle test tasks...]: compiles the JVM main and test code of every module, offline, then runs
# the given test tasks (a task's grade.sh names the tests of the modules it touches; the whole suite takes hours).
# Non-JVM targets are not compiled: no Kotlin/Native toolchain, Node or Android SDK exists in the grading sandbox.
off=--offline; [ "${1:-}" = online ] && { off=; shift; }
G="./gradlew --no-daemon $off -q --init-script /project/grade-toolchain.gradle -Porg.gradle.java.installations.auto-download=false --no-configuration-cache --continue"
if [ -z "$off" ]; then
  # grade-setup: also resolve what the JVM tests need at run time.
  cat > /tmp/study-resolve.gradle <<'G'
allprojects {
  def cs = configurations
  tasks.register("studyResolveJvm") {
    doLast { cs.findAll { it.canBeResolved && it.name.startsWith("jvm") }.each { c -> try { c.resolve() } catch (Exception e) { } } }
  }
}
G
  $G --init-script /tmp/study-resolve.gradle studyResolveJvm > /tmp/gradle-resolve.log 2>&1 || { tail -40 /tmp/gradle-resolve.log; exit 1; }
fi
$G compileTestKotlinJvm "$@" > /tmp/gradle.log 2>&1
rc=$?
tail -80 /tmp/gradle.log
exit $rc
