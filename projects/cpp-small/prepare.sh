#!/bin/sh
# clangd's compilation database for tinyxml2, written without a compiler (the server sandbox has none): every C++
# translation unit in the tree with the flags of the CMake build (CMakeLists.txt: library and xmltest, Debug; contrib/
# the same way), paths under /workspace. Runs in the snapshot (/workspace) at each commit; git-ignored there.
set -eu
printf 'compile_commands.json\n' >> .git/info/exclude
git ls-files '*.cpp' | jq -R -s 'split("\n") | map(select(length > 0)) | map({directory: "/workspace",
  file: ("/workspace/" + .), arguments: ["c++", "-std=gnu++17", "-g", "-DTINYXML2_DEBUG", "-D_FILE_OFFSET_BITS=64",
  "-I/workspace", "-c", ("/workspace/" + .)]})' > compile_commands.json
