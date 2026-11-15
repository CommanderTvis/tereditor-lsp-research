For the next major release we will delete every method of the `gson/` module's main code
(`gson/src/main/java`) that is annotated `@Deprecated`. Before that, I need to know which of the files below call at
least one of those deprecated methods (directly, in code; method references count, comments and Javadoc do not):

- `gson/src/main/java/com/google/gson/internal/bind/MapTypeAdapterFactory.java`
- `gson/src/main/java/com/google/gson/internal/bind/ReflectiveTypeAdapterFactory.java`
- `gson/src/main/java/com/google/gson/internal/bind/util/ISO8601Utils.java`
- `gson/src/main/java/com/google/gson/internal/sql/SqlTimeTypeAdapter.java`
- `gson/src/test/java/com/google/gson/JsonObjectTest.java`
- `gson/src/test/java/com/google/gson/MixedStreamTest.java`
- `gson/src/test/java/com/google/gson/functional/DefaultTypeAdaptersTest.java`
- `gson/src/test/java/com/google/gson/functional/RuntimeTypeAdapterFactoryFunctionalTest.java`
- `gson/src/test/java/com/google/gson/stream/JsonReaderTest.java`
- `gson/src/test/java/com/google/gson/stream/JsonWriterTest.java`

Only deprecated methods of gson's own main code matter: deprecated constructors, deprecated JDK methods and
non-deprecated overloads of the same name do not count.

Write the result to `ANSWER.txt` in the repository root: the files from this list that call such a method, one path
per line exactly as written above.
