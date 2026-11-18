# Oracle: impls-scorable

Derived from the compiler's output, not from a language server: `./gradlew compileTestJava` at the pinned commit, then a
JDK 21 program (reflection over every `build/classes/java/main` directory of the repository's modules, build-tools
excluded, with the resolved dependency jars on the class path; 6933 classes, all loadable) that lists the
non-abstract, non-interface, non-anonymous, non-local classes `c` with `Scorable.class.isAssignableFrom(c)`, by
canonical name (a dot between outer and nested class). That gives 49 classes; the 4 declared in `lucene/test-framework`
(`org.apache.lucene.tests.search.*`) are removed, because the prompt scopes the question to production modules, leaving
45. Judgement calls: nested named classes count; classes in modules other than core (join, facet, sandbox, queries,
grouping) count; generated sources contribute none.
