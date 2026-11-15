#!/bin/sh
# Build and test the gson module offline.
mvn -B -q -o -pl gson -am test > /tmp/mvn.log 2>&1
rc=$?
tail -60 /tmp/mvn.log
exit $rc
