#!/bin/sh
# Server side, with network: resolve the Gradle build once, for both servers' import: the wrapper's distribution, the
# convention plugins of buildSrc and every resolvable configuration of the modules the study builds, into
# /cache/home/.gradle; the main and test sources of those modules are compiled once to fetch the compiler plugins and
# annotation processors. Outputs are deleted again (the servers index from scratch). GITHUB_WORKFLOW is the project's
# own switch that leaves out the Clojure module.
set -eu
export GITHUB_WORKFLOW=study
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
./gradlew --no-daemon --no-configuration-cache -q --init-script /tmp/study-resolve.gradle studyResolveAll \
  :core:support:testClasses :core:pactbroker:testClasses :core:model:testClasses :core:matchers:testClasses \
  :consumer:testClasses :provider:testClasses
find . \( -name build -o -name .gradle \) -type d -prune -not -path './gradle/*' -exec rm -rf {} + 2>/dev/null || true
