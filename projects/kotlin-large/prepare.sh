#!/bin/sh
# Resolves the Gradle build once, for both servers' import: the wrapper's distribution, the build logic and every
# resolvable configuration of every module, into /cache/home/.gradle. Only ktor-utils' JVM code is compiled, to
# provision the JDK 8 toolchain the build asks for; its outputs are deleted again.
set -eu
cat > /tmp/study-resolve.gradle <<'G'
allprojects {
  def cs = configurations
  def p = path
  tasks.register("studyResolveAll") {
    doLast {
      cs.findAll { it.canBeResolved }.each { c ->
        try { c.resolve() } catch (Exception e) { println("study: unresolved ${p}:${c.name}") }
      }
    }
  }
}
G
./gradlew --no-daemon --no-configuration-cache -q --init-script /tmp/study-resolve.gradle studyResolveAll :ktor-utils:compileKotlinJvm
rm -rf ktor-utils/build ktor-io/build
