#!/bin/sh
# Inside the server sandbox, in the project's snapshot (/workspace), network on: the project's own prepare.sh, with the
# managed runtimes tereditor installed (for example dotnet restore with the pinned .NET SDK).
set -eu
export TEREDITOR_TOOLCHAINS=managed TEREDITOR_MANAGED_CACHE=/cache/managed TEREDITOR_STATE_DIR=/cache/state
sh /study/lsplog/prepare.sh
# A Maven wrapper downloads its Maven distribution on first use; do it here, where the proxy settings are present, so
# IntelliJ's Maven import (which runs the wrapper without them) finds it in ~/.m2/wrapper.
if [ -f mvnw ] && [ -f .mvn/wrapper/maven-wrapper.properties ]; then sh ./mvnw -B -q -v > /dev/null || echo "prepare: mvnw -v failed" >&2; fi
