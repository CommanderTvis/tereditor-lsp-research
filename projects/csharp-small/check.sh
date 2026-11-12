#!/bin/sh
# Build-and-test for MediatR, offline: restore from the image's package cache, build the whole solution (library,
# tests, samples), run the unit tests.
set -e
dotnet restore MediatR.sln
dotnet build MediatR.sln --no-restore -nologo -v q
dotnet test test/MediatR.Tests/MediatR.Tests.csproj --no-build -nologo -v q
