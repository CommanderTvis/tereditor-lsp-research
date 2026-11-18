#!/bin/sh
# Run from a checkout of the pinned commit configured with cmake -DDISABLE_UNITY=1 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
# (compile_commands.json path in $1). vt.cpp includes the six leaf join headers. Prints, per class, the methods it
# declares, and for the intermediate classes the methods that override a PhysicalOperator virtual.
set -e
cc=$1
for h in asof_join blockwise_nl_join hash_join iejoin nested_loop_join piecewise_merge_join; do echo "#include \"duckdb/execution/operator/join/physical_$h.hpp\""; done > /tmp/vt.cpp
cmd=$(jq -r '.[] | select(.file | endswith("src/execution/physical_plan_generator.cpp")) | .command' "$cc" | sed -E 's/ -o [^ ]+//; s|-c [^ ]+physical_plan_generator.cpp||')
for c in PhysicalAsOfJoin PhysicalBlockwiseNLJoin PhysicalHashJoin PhysicalIEJoin PhysicalNestedLoopJoin PhysicalPiecewiseMergeJoin CachingPhysicalOperator PhysicalJoin PhysicalComparisonJoin PhysicalRangeJoin; do
  echo "== $c"
  eval "$cmd -fsyntax-only -Xclang -ast-dump -Xclang -ast-dump-filter=duckdb::$c /tmp/vt.cpp" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' \
    | grep -E '^\|-CXXMethodDecl|Overrides:' | sed -E 's/0x[0-9a-f]+//g; s|</[^>]*>||' | cut -c1-160
done
