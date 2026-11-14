#!/bin/sh
# Dependencies for grading, resolved once with network (packages into ~/.nuget, build outputs kept as the overlay).
set -e
dotnet restore MediatR.sln
dotnet build MediatR.sln --no-restore -v q -nologo
