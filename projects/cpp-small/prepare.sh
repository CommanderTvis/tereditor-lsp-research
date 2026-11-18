#!/bin/sh
# clangd's compilation database for MD4C, written without a compiler (the server sandbox has none): every C file in the
# tree with the flags of the CMake build (src/CMakeLists.txt, md2html/CMakeLists.txt: Debug, library sources with
# -I src, md2html with its version defines), paths under /workspace. Runs in the snapshot (/workspace) at each commit;
# git-ignored there.
set -eu
printf 'compile_commands.json\n' >> .git/info/exclude
git ls-files '*.c' | jq -R -s 'split("\n") | map(select(length > 0)) | map({directory: "/workspace",
  file: ("/workspace/" + .), arguments: (["cc", "-std=gnu99", "-g", "-DDEBUG", "-I/workspace/src",
  "-DMD_VERSION_MAJOR=0", "-DMD_VERSION_MINOR=6", "-DMD_VERSION_RELEASE=0", "-c", ("/workspace/" + .)])})' > compile_commands.json
