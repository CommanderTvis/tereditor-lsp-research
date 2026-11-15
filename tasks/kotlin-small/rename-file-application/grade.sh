#!/bin/sh
# The file is renamed (old path gone, new path present), everything builds and the tests pass, and the main class the
# example's build launches exists among the compiled classes (a build script left pointing at ApplicationKt fails).
d=example/src/main/kotlin/com/github/michaelbull/result/example
[ ! -e "$d/Application.kt" ] || { echo "grade: Application.kt still exists"; exit 1; }
grep -q 'fun main()' "$d/Main.kt" || { echo "grade: no Main.kt with main()"; exit 1; }
sh /project/check.sh || exit 1
mc=$(./gradlew --no-daemon --offline -q --init-script /project/grade-toolchain.gradle --init-script /task/main-class.gradle \
  :example:studyMainClass | sed -n 's/^STUDY_MAIN_CLASS=//p')
echo "main class: $mc"
[ -n "$mc" ] && [ -f "example/build/classes/kotlin/main/$(echo "$mc" | tr . /).class" ]
