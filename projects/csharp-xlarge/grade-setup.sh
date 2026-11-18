#!/bin/sh
# Dependencies for grading, resolved once with network: packages into ~/.nuget/packages (the grading home); obj/ and
# bin/ are git-ignored and kept as the overlay copied into every grading work tree.
set -e
sh /project/check.sh build
