#!/bin/sh
# Dependencies for grading, resolved once with network: the wrapper, the build logic, the library modules compiled with their
# tests (the outputs stay in the grade home's build cache, so grading recompiles only what a patch affects), and every resolvable
# configuration of those modules, the test runtime included.
set -e
sh /project/check.sh online
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
./gradlew --no-daemon --no-configuration-cache -q -Porg.gradle.java.installations.auto-download=false -Dorg.gradle.jvmargs=-Xmx2500m --init-script /tmp/study-resolve.gradle \
  :core:studyResolveAll :dataframe-json:studyResolveAll :dataframe-csv:studyResolveAll :dataframe-arrow:studyResolveAll :dataframe-excel:studyResolveAll :samples:studyResolveAll :common-test-utils:studyResolveAll
