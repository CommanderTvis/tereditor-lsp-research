# Oracle: which GetSources() runs for a PhysicalNestedLoopJoin

Derived with clang, not a language server: `derive-oracle.sh` dumps the AST (`-Xclang -ast-dump -Xclang -ast-dump-filter`, Apple clang 21 with the build's flags) of the six leaf join classes and the intermediate classes. `PhysicalNestedLoopJoin` and `PhysicalComparisonJoin` declare no `GetSources`; `PhysicalJoin::GetSources` (`physical_join.hpp:43`) is declared `override` of `PhysicalOperator::GetSources`, and its only definition is `src/execution/operator/join/physical_join.cpp:89`. The other definitions of `GetSources` (`PhysicalOperator`, `PhysicalCrossProduct`, `PhysicalPositionalJoin`, `PhysicalUnion`, ...) belong to classes outside the object's chain.

No judgement calls.
