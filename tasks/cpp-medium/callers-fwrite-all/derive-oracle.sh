#!/bin/sh
# Derives oracle.txt with clang's static-analyzer call graph, not a language server: the call graphs of the two
# translation units of the compiled library, then every exported entry point (entry-points.txt) that reaches the
# target through any chain of calls. Run from a checkout of the pinned commit: sh derive-oracle.sh <fmt-checkout>
set -e
here=$(cd "$(dirname "$0")" && pwd); cd "$1"
for f in src/format.cc src/os.cc; do
  clang++ -std=c++17 -Iinclude --analyze -Xclang -analyzer-checker=debug.DumpCallGraph -o /dev/null "$f" 2>&1 | grep '^  Function:'
done > /tmp/fmt-callgraph.txt
uv run --no-project python "$here/callers.py" "$here/entry-points.txt" /tmp/fmt-callgraph.txt \
  | awk -F'\t' '$1 == "fmt::detail::fwrite_all" {print $3}' | tr ' ' '\n'
