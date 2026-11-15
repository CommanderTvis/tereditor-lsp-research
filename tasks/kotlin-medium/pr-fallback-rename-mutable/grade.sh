#!/bin/sh
# No call or declaration of a function named mutable is left in Kotlin or Java code (the PropertySpec.mutable property
# and the builder's field keep their name), then everything builds and the tests, with the hidden one, pass.
if grep -rnE --include=*.kt --include=*.java '\bmutable\(' kotlinpoet interop; then
  echo "grade: mutable( is still called or declared"; exit 1
fi
sh /project/check.sh
