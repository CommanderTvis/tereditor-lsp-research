# Oracle: exported functions outside fmt::detail that reach fmt::detail::fwrite_all

Derived with clang's static-analyzer call graph, not a language server: `derive-oracle.sh` (Apple clang 21 on the
host, `clang++ -std=c++17 -Iinclude --analyze -Xclang -analyzer-checker=debug.DumpCallGraph` on `src/format.cc` and
`src/os.cc`, the two translation units of the compiled library on Linux and macOS), then a transitive closure from the
28 exported entry points that match `entry-points.txt` (the `FMT_API` declarations outside `fmt::detail`; members of
the `FMT_API` classes `file` and `pipe` included).

Result: `fmt::vprint`, `fmt::vprint_buffered`, `fmt::vprintln`. Checked by hand in `include/fmt/format-inl.h`:
`fwrite_all` has three callers, `detail::vprint_mojibake` (only under `_WIN32`), `detail::print(FILE*, string_view)`
and nothing else; `detail::print` is called by `vprint_buffered` and `vprintln`; `vprint(FILE*, ...)` calls
`vprint_buffered`, and `vprint(string_view, ...)` calls `vprint(stdout, ...)`. The templates `fmt::print` and
`fmt::println` in `base.h` also reach it but are not exported.

Judgement calls: overloads are merged by name (stated in the prompt); calls through function pointers are not edges
of the call graph, and none leads to `fwrite_all` (its callers are all direct calls).
