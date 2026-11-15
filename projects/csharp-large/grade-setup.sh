#!/bin/sh
# Dependencies for grading, resolved once with network: packages into ~/.nuget/packages (the grading home); obj/ and
# bin/ are git-ignored and kept as the overlay copied into every grading work tree. At an older commit a test project
# that does not build with the current SDK is reported and does not stop the others (check.sh build).
set -e
sh /project/check.sh build
