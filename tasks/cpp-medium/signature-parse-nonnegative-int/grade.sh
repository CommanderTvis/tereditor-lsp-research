#!/bin/sh
# The held-out program (which calls the function with the new order, passing the end as an rvalue, and exercises every
# caller through format and sprintf) builds and passes; then the project's build and tests.
set -e
c++ -std=gnu++17 -DFMT_HEADER_ONLY -Iinclude test/study-hidden-signature.cc -o /tmp/study-hidden-signature
/tmp/study-hidden-signature
sh /project/check.sh
