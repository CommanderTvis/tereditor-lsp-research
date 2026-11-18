The first step of the consumer DSL, `PactDslRequestWithoutPath` (`consumer/src/main/kotlin/au/com/dius/pact/consumer/dsl/PactDslRequestWithoutPath.kt`),
is what `uponReceiving(...)` returns before a path has been chosen. Its sibling that follows it is called
`PactDslRequestWithPath`, and "WithoutPath" reads badly next to it in the generated documentation. We want to call it
`PactDslRequestNoPath`.

Rename the class `PactDslRequestWithoutPath` to `PactDslRequestNoPath` everywhere in the repository: its declaration,
every use in Kotlin and Java code, the Spock specs and other tests, KDoc and Javadoc references, and the Markdown
documentation. Rename its source file to `PactDslRequestNoPath.kt` so it keeps matching the class. `PactDslRequestWithPath`
and the spec class names (`PactDslRequestWithoutPathSpec`) are separate names and are not part of this change.

The modules must still build and the existing tests must pass.
