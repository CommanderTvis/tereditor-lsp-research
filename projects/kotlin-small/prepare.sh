#!/bin/sh
# Resolves the Gradle build once, for both servers' import: the wrapper's distribution, the JDK 8 toolchain the build
# asks for (foojay) and every resolvable configuration of every module, into /cache/home/.gradle. The JVM main source
# sets are compiled only to provision the toolchain; the outputs are deleted again (the servers index from scratch).
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
./gradlew --no-daemon --no-configuration-cache -q --init-script /tmp/study-resolve.gradle studyResolveAll :kotlin-result:compileKotlinJvm
for d in build */build; do [ "$d" = buildSrc/build ] || rm -rf "$d"; done
