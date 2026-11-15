#!/bin/sh
# ParameterSpec.kt is moved (old path gone, new path present in the new package) and ParameterSpec is declared only
# there; then everything builds and the tests, with the hidden one in the new package, pass.
r=kotlinpoet/src/jvmMain/kotlin/com/squareup/kotlinpoet
[ ! -e "$r/ParameterSpec.kt" ] || { echo "grade: ParameterSpec.kt is still in the old directory"; exit 1; }
grep -qx 'package com.squareup.kotlinpoet.parameterspec' "$r/parameterspec/ParameterSpec.kt" \
  || { echo "grade: parameterspec/ParameterSpec.kt missing or wrong package"; exit 1; }
decl=$(grep -rlE '^(public )?class ParameterSpec\b' --include=*.kt . | sort -u)
[ "$decl" = "./$r/parameterspec/ParameterSpec.kt" ] || { echo "grade: ParameterSpec declared in: $decl"; exit 1; }
sh /project/check.sh
