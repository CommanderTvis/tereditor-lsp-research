#!/bin/sh
# No qualified use of the old name is left; the held-out program (which names fmt::iterator_buffer and declares a
# variable fmt::detail::iterator_buffer, which clashes with anything of that name left in detail) builds and passes;
# then the project's build and tests.
set -e
if grep -rn 'detail::iterator_buffer' include src test; then exit 1; fi
c++ -std=gnu++17 -DFMT_HEADER_ONLY -Iinclude test/study-hidden-move.cc -o /tmp/study-hidden-move
/tmp/study-hidden-move
sh /project/check.sh
