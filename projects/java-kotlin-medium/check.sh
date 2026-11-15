#!/bin/sh
set -e
mvn -B -q -o test > gradle-study-maven.log 2>&1
rc=$?
tail -60 gradle-study-maven.log
exit $rc
