The oracle is derived in the grading sandbox by `derive-oracle.sh`. It
compiles the project and enumerates named JVM classes with
`Taggable.class.isAssignableFrom`, excluding the target type and anonymous
classes. The language server is not used.

Run (JDK 21, no network) with `derive-run.sh`, the host-side wrapper that copies the pinned snapshot into the grading sandbox
and runs `derive-oracle.sh`: 15 named types, the 15 listed in `oracle.txt`. `TypeName` is the sealed class in between, so
its subclasses (`ClassName`, `ParameterizedTypeName`, `LambdaTypeName`, `TypeVariableName`, `WildcardTypeName`, `Dynamic`)
count; `Taggable.Builder` and its implementations do not unless they are also `Taggable` (none are). No judgement calls.
