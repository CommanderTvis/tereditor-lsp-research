#!/bin/sh
# clangd's compilation database for DuckDB, written without a compiler (the server sandbox has none): every C++ file of
# src/, extension/, tools/ and test/ with C++17 and the include directories of the CMake build (src/include, the
# extensions' include directories, test/include, and each include directory of third_party), paths under /workspace.
# Runs in the snapshot (/workspace) at each commit; git-ignored there.
set -eu
printf 'compile_commands.json\n' >> .git/info/exclude
inc=$( { echo src/include; echo test/include; echo third_party/catch; echo third_party/sqlite/include
         find extension -type d -name include; find third_party -maxdepth 3 -type d -name include
         find third_party -maxdepth 1 -mindepth 1 -type d; } | sort -u | sed 's|^|-I/workspace/|' | jq -R . | jq -s .)
git ls-files 'src/*.cpp' 'extension/*.cpp' 'tools/*.cpp' 'test/*.cpp' | grep -v '/third_party/' | jq -R -s --argjson inc "$inc" '
  split("\n") | map(select(length > 0)) | map({directory: "/workspace", file: ("/workspace/" + .),
  arguments: (["c++", "-std=c++17", "-DDUCKDB_BUILD_LIBRARY"] + $inc + ["-c", ("/workspace/" + .)])})' > compile_commands.json
