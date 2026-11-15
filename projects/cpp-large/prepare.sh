#!/bin/sh
# clangd's compilation database for Redis, written without a compiler (the server sandbox has none): every C file of
# the server and tools (src/), the module API test modules (tests/modules/) and the vector-sets module (modules/),
# with the include paths and defines of their Makefiles (src: gnu11, REDIS_TEST as check.sh builds it, the vendored
# hiredis, linenoise, lua, hdr_histogram, fpconv and xxhash headers; modules: src/ for redismodule.h). Vendored deps/
# are not listed (their headers are indexed through the files that include them). Paths under /workspace. Runs in the
# snapshot (/workspace) at each commit; git-ignored there.
set -eu
printf 'compile_commands.json\n' >> .git/info/exclude
git ls-files 'src/*.c' 'tests/modules/*.c' 'modules/*.c' | jq -R -s '
  split("\n") | map(select(length > 0)) | map(. as $f
  | (if ($f | startswith("src/")) then ["-std=gnu11", "-DREDIS_TEST", "-DINCLUDE_VEC_SETS=1"]
       + (["hiredis", "linenoise", "lua/src", "hdr_histogram", "fpconv", "xxhash"] | map("-I/workspace/deps/" + .))
     else ["-std=gnu11", "-I/workspace/src", ("-I/workspace/" + ($f | sub("/[^/]*$"; "")))] end) as $flags
  | {directory: ("/workspace/" + ($f | sub("/[^/]*$"; ""))), file: ("/workspace/" + $f),
     arguments: (["cc"] + $flags + ["-c", ("/workspace/" + $f)])})' > compile_commands.json
