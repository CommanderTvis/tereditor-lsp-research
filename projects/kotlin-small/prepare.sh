#!/bin/sh
# Server side, with network: resolve the Gradle build once, for both servers' import: the wrapper's distribution and
# every resolvable configuration, into /cache/home/.gradle; the main and test sources are compiled once to fetch the
# compiler plugins. The build asks for a JDK 26 toolchain the sandbox does not have, so an init script (kept in
# /cache/home/.gradle/init.d, which the servers' imports read too) selects JDK 21; it acts on this project only, because
# that directory is shared by every project the servers import. Outputs are deleted again (the
# servers index from scratch).
set -eu
mkdir -p "$HOME/.gradle/init.d"
cat > "$HOME/.gradle/init.d/study-toolchain.gradle" <<'G'
allprojects {
  afterEvaluate {
    if (rootProject.name != 'compose-lints') return
    def java = extensions.findByType(JavaPluginExtension)
    if (java != null) java.toolchain.languageVersion.set(JavaLanguageVersion.of(21))
  }
}
G
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
  :compose-lint-checks:compileKotlin :compose-lint-checks:compileTestKotlin
find . -name build -type d -prune -not -path './gradle/*' -exec rm -rf {} +
