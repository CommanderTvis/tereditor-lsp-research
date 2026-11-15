The oracle is derived in the grading sandbox by `derive-oracle.sh`. It
compiles the project and enumerates named JVM classes with
`Taggable.class.isAssignableFrom`, excluding the target type and anonymous
classes. The language server is not used.
