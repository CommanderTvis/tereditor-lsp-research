# Oracle: which of ten Redis server files declare a variable that shadows a local of an enclosing scope

Derived with clang, not a language server: `derive-oracle.sh` (Apple clang 21 on the host, `clang -fsyntax-only
-Wno-everything -Wshadow` with the include paths and defines of the server's Makefile, `REDIS_TEST` included as
`check.sh` builds it). A file is a positive if clang reports "declaration shadows a local variable" at a location in
the file itself that does not come from a macro expansion.

Positives (each instance is an inner declaration reusing the name of an outer local or parameter):

- `src/lolwut8.c:163` (`size_t j` in a for loop inside a loop over `j`)
- `src/module.c:6625`, `:7116`, `:11856`, `:11877`
- `src/redis-check-aof.c:311` (`char buf[2]`)
- `src/sentinel.c:2917`, `:4304`, `:4305`, `:5280`, `:5281`
- `src/t_hash.c:3830`

Decoys: `src/commands.c`, `src/debug.c`, `src/lolwut6.c`, `src/socket.c`, `src/sort.c`: no report at all.

Judgement calls:

- Branches the macOS compile does not take: `src/lolwut6.c`, `src/socket.c` and `src/sort.c` have no conditional
  compilation; `src/commands.c` is a 13-line file around `#include "commands.def"` (tables, no functions);
  `src/debug.c` was also checked in four preprocessed variants (`unifdef` for Linux x86_64 with jemalloc, crash
  report and GCRA on; Linux AArch64; FreeBSD; OpenBSD i386; missing Linux headers stubbed so parsing continues):
  no report in any. Every positive has its instance in code compiled on all platforms.
- Files whose only reports come from macro expansions (`src/mstr.c`) were excluded from both pools, so no candidate
  depends on how macros are read.
