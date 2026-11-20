#!/bin/sh
# The contract, the dispatcher and the fake take the new parameter; the scheduler's own protected method does not.
set -e
grep -q 'function dispatchNow(\$command, array \$context, \$handler = null)' src/Illuminate/Contracts/Bus/Dispatcher.php src/Illuminate/Bus/Dispatcher.php src/Illuminate/Support/Testing/Fakes/BusFake.php
grep -q 'function dispatchNow(\$job)' src/Illuminate/Console/Scheduling/Schedule.php
sh /project/check.sh tests/Support/SupportTestingBusFakeTest.php tests/Bus tests/Queue tests/Console
