# Oracle: calls of InvalidFormatException.from (jackson-databind 3.3.0)

Derived without a language server, from the compiler (`derive-oracle.sh`, run in the grading sandbox with JDK 21 on
the pinned snapshot, `derive-run.sh` is its host-side wrapper): every `.java` of `src/main/java` and `src/test/java`
compiles with the Maven test classpath (0 errors); the declaration `public static InvalidFormatException from(...)`
(InvalidFormatException.java:37, the only one) is renamed and the sources compiled again: 8 errors, one per call, all
reported at the line of the call's method name. The text candidates agree: `rg -n 'InvalidFormatException\.from\('
src` lists the same 8 lines (6 call sites in 2 main files, 2 in tests). `InvalidFormatException` extends
`MismatchedInputException`, which has its own static `from`; the calls still fail to compile after the rename because
the inherited overload is not applicable to their arguments (javac says "no suitable method found"), so the
compiler distinguishes them from calls of the sibling classes' `from` factories (`InvalidDefinitionException.from`,
`MismatchedInputException.from`, ...), which are not in the oracle.

Judgement calls: none. The Javadoc and comments that mention `InvalidFormatException.from` are not calls and are not listed.
