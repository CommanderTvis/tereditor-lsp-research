#!/bin/sh
# clangd's compilation database for fmt, written without a compiler (the server sandbox has none): every C and C++
# translation unit in the tree except the C++20 module unit (src/fmt.cc, test/module-test.cc), with the flags of the
# CMake build (-DFMT_TEST=ON): include/ for everything; for tests also GTEST_HAS_STD_WSTRING and the bundled gtest; the
# header-only tests with FMT_HEADER_ONLY. Paths under /workspace. Runs in the snapshot (/workspace) at each commit;
# git-ignored there.
set -eu
printf 'compile_commands.json\n' >> .git/info/exclude
git ls-files '*.cc' '*.c' | grep -v -e '^src/fmt\.cc$' -e '^test/module-test\.cc$' -e '^doc/' | jq -R -s '
  split("\n") | map(select(length > 0)) | map(. as $f
  | (if ($f | startswith("test/")) then ["-DGTEST_HAS_STD_WSTRING=1", "-isystem", "/workspace/test/gtest"] else [] end) as $t
  | (if ($f | test("^test/(format-impl|header-only|no-builtin-types|scan|unicode)-test\\.cc$")) then ["-DFMT_HEADER_ONLY=1"] else [] end) as $h
  | {directory: "/workspace", file: ("/workspace/" + $f),
     arguments: ((if ($f | endswith(".c")) then ["cc", "-std=c11"] else ["c++", "-std=gnu++17"] end) + $h + $t
                 + ["-I/workspace/include", "-c", ("/workspace/" + $f)])})' > compile_commands.json
