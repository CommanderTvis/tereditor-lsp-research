#!/bin/sh
# Derives the references oracle by compiler-driven rename (docs/TASKS.md): rename the declaration of
# RegexMatchOperatorSemantics (the enum and its forward declaration), compile the translation units that mention it,
# and collect every location clang reports an unknown name at. Run from a checkout of the pinned commit with a
# compile_commands.json (cmake -DDISABLE_UNITY=1 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON) path as $1.
set -e
cc=$1
sed -i.bak 's/enum class RegexMatchOperatorSemantics /enum class RegexMatchOperatorSemanticsRenamed /' src/include/duckdb/common/enums/regex_match_operator_semantics.hpp src/include/duckdb/common/enum_util.hpp
for f in src/common/enum_util.cpp src/main/settings/custom_settings.cpp src/parser/peg/transformer/transform_expression.cpp; do
  cmd=$(jq -r --arg f "$PWD/$f" '.[] | select(.file == $f) | .command' "$cc")
  # replace the output and add -fsyntax-only; keep the build's own include paths and defines
  eval "$(printf '%s' "$cmd" | sed -E 's/ -o [^ ]+//; s/ -c / -fsyntax-only -ferror-limit=0 -fno-caret-diagnostics -c /')" 2>&1 | grep ' error: ' || true
done | sed -E "s|^$PWD/||" | awk -F: '{print $1":"$2}' | sort -u
find . -name '*.bak' -delete; git checkout -q src
