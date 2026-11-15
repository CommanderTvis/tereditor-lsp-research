#!/bin/sh
# The pull request's xmltest.cpp (held out, copied over the agent's) built against the library and run from the tree
# root: it exits non-zero unless every check passes (", Fail 0"), so this covers its fail-to-pass checks and every
# other check of the suite (pass to pass).
set -e
c++ -std=gnu++11 -w tinyxml2.cpp xmltest.cpp -o /tmp/xmltest
/tmp/xmltest > /tmp/xmltest.log 2>&1 || { tail -40 /tmp/xmltest.log; exit 1; }
tail -n 3 /tmp/xmltest.log
grep -q ', Fail 0' /tmp/xmltest.log
