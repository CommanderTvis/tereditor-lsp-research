#!/bin/sh
# Build and test offline. Six tests fail on JDK 21 at the pinned commit, independently of any change (Mockito 2 cannot
# mock JDK 21 classes; javac 21 reports different notes and parameter names): they are excluded.
. /project/pom-jdk21.sh
mvn -B -q -o test -Dsurefire.failIfNoSpecifiedTests=false \
  -Dtest='!ClassNameTest#classNameFromTypeElementDoesntUseGetKind,!FileWritingTest#filerPassesOriginatingElements,!TypeSpecTest#modifyOriginatingElements,!TypeSpecTest#originatingElementsIncludesThoseOfNestedTypes,!FileReadingTest#compileJavaFile,!ParameterSpecTest#parameterVariableElement' \
  > /tmp/mvn.log 2>&1
rc=$?
tail -60 /tmp/mvn.log
exit $rc
