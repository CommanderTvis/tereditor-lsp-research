#!/bin/sh
# Dependencies for grading, resolved once with network: packages into ~/.nuget/packages (the grading home); obj/ and
# bin/ are git-ignored and kept as the overlay copied into every grading work tree. Every graded test project is built.
set -e
TEST_PROJECTS="EFCore.Tests EFCore.InMemory.FunctionalTests EFCore.Sqlite.FunctionalTests Microsoft.Data.Sqlite.Tests dotnet-ef.Tests" sh /project/check.sh build
