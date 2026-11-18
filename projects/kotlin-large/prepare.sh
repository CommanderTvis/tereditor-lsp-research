#!/bin/sh
# Server side, with network: resolves the Gradle build once, for both servers' import: the wrapper's distribution, the build
# logic and every resolvable configuration of every module, into /cache/home/.gradle (the kotlinlang bootstrap Maven
# repository is reached here; the build asks for Kotlin dev builds from it). Nothing is written to the shared Gradle home:
# the heap is a command-line option (the project's gradle.properties asks for 5 GB, the container has 4).
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
./gradlew --no-daemon --no-configuration-cache -q -Dorg.gradle.jvmargs="-Xmx2500m -XX:MaxMetaspaceSize=1g -Dfile.encoding=UTF-8" --init-script /tmp/study-resolve.gradle studyResolveAll
