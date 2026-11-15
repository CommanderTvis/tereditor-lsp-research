#!/bin/sh
# Resolves the Gradle build once, for both servers' import: the wrapper's distribution and every resolvable
# configuration of every module, into /cache/home/.gradle. Nothing is compiled.
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
./gradlew --no-daemon --no-configuration-cache -q --init-script /tmp/study-resolve.gradle studyResolveAll
