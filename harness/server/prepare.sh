#!/bin/sh
# Inside the server sandbox, in the project's snapshot (/workspace), network on: the project's own prepare.sh, with the
# managed runtimes tereditor installed (for example dotnet restore with the pinned .NET SDK).
set -eu
export TEREDITOR_TOOLCHAINS=managed TEREDITOR_MANAGED_CACHE=/cache/managed TEREDITOR_STATE_DIR=/cache/state
sh /study/lsplog/prepare.sh
