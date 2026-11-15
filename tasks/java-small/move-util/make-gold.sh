#!/bin/bash
# Reference solution of java-small/move-util, run at the repository root of the pinned snapshot.
set -e
d=src/main/java/com/squareup/javapoet
mkdir -p $d/internal && git mv $d/Util.java $d/internal/Util.java
perl -pi -e 's/^package com\.squareup\.javapoet;/package com.squareup.javapoet.internal;/; s/^final class Util \{/public final class Util {/; s/^  static /  public static /' $d/internal/Util.java
for f in $(git grep -l 'import static com.squareup.javapoet.Util\.' -- '*.java'); do
  perl -pi -e 's/^import static com\.squareup\.javapoet\.Util\./import static com.squareup.javapoet.internal.Util./' $f
done
for f in $(git grep -nE '(^|[^".A-Za-z0-9_])Util\.[a-z]' -- 'src/*.java' | grep -v ':import ' | cut -d: -f1 | sort -u); do
  perl -0pi -e 's/^(package com\.squareup\.javapoet;\n\n)/$1import com.squareup.javapoet.internal.Util;\n/m' $f
done
