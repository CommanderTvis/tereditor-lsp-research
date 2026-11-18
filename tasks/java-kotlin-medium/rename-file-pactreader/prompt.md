The Kotlin file `core/model/src/main/kotlin/au/com/dius/pact/core/model/PactReader.kt` holds the pact loading helpers and
the top-level functions `loadPactFromUrl`, `fetchJsonResource` and `queryStringToMap`, next to the `PactReader`
interface and its default implementation. We want the file name to say it is a collection of helpers: rename the file to
`PactReaderUtils.kt` (same directory).

Top-level functions of a Kotlin file are exposed to Java and Groovy as static methods of a class named after the file, so
the class they are called through changes with the file name. Update every place that uses the functions through that
class: Java code, Groovy specs and fixtures, and the compatibility suite. The `PactReader` interface, the
`DefaultPactReader` object and the package stay as they are, no file named `PactReader.kt` may remain, and the
modules must still build and the existing tests must pass.
