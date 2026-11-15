#!/bin/sh
# Sourced by grade-setup.sh and check.sh in the grading copy: the pom compiles through Error Prone 2.3.1
# (plexus-compiler-javac-errorprone), which does not run on JDK 21; compile with plain javac instead (the compiler
# plugin's errorprone compiler id and its dependencies are dropped). Only the grading copy is changed.
awk '/<compilerId>javac-with-errorprone</ || /<forceJavacCompilerUse>/ {next}
     /<artifactId>maven-compiler-plugin</ {inplugin=1}
     inplugin && /<dependencies>/ {skip=1}
     skip {if (/<\/dependencies>/) {skip=0; inplugin=0}; next}
     {print}' pom.xml > /tmp/pom.jdk21.xml && cp /tmp/pom.jdk21.xml pom.xml
