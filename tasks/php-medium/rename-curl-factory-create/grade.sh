#!/bin/sh
# Renamed in the interface and its implementation, nothing calls the old name, the static create() methods remain.
set -e
grep -q 'public function createEasyHandle(RequestInterface \$request, array \$options): EasyHandle;' src/Handler/CurlFactoryInterface.php
! grep -n 'function create(' src/Handler/CurlFactoryInterface.php src/Handler/CurlFactory.php
grep -q 'public static function create(' src/Exception/RequestException.php
grep -q 'public static function create(' src/HandlerStack.php
sh /project/check.sh
