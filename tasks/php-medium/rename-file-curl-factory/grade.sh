#!/bin/sh
# The old file and class name are gone from the code, the new file declares the class, the interface keeps its name.
set -e
test ! -e src/Handler/CurlFactory.php
grep -q '^final class CurlHandleFactory implements CurlFactoryInterface' src/Handler/CurlHandleFactory.php
test -f src/Handler/CurlFactoryInterface.php
grep -q '^interface CurlFactoryInterface' src/Handler/CurlFactoryInterface.php
sh /project/check.sh
