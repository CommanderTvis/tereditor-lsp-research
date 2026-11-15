# Oracle: which candidate files call a deprecated gson method

Derived with javac, not a language server: `derive-oracle.sh`, run with JDK 21 and Maven 3.9.11 on the snapshot
(`sh derive-oracle.sh /path/to/snapshot`).

1. Compile every `.java` under `gson/src/main/java`, `gson/src/test/java` and the module's generated sources with the
   module's test-scope classpath: no errors.
2. Rename every method annotated `@Deprecated` in `gson/src/main/java` (14 declarations: `Gson.excluder`,
   `GsonBuilder.setLenient()` and `setDateFormat(int)`, `getAsCharacter` in `JsonElement`, `JsonArray` and
   `JsonPrimitive`, the three `JsonParser.parse` instance methods, the three `TypeToken.isAssignableFrom`,
   `JsonReader.setLenient`, `JsonWriter.setLenient`) and compile again: 13 files get errors.
3. The 9 files that declare these methods are excluded from both pools (2 of them, `JsonArray.java` and
   `TypeToken.java`, call deprecated methods internally); 11 files remain: the true pool.

The 5 true candidates (`oracle.txt`) were each checked by reading: every one calls a deprecated method
(`JsonReader.setLenient`, `JsonWriter.setLenient`, `GsonBuilder.setDateFormat(int)`, `JsonElement.getAsCharacter`);
none of them only overrides one. The 5 decoys contain the same method names on other receivers or overloads
(`Calendar.setLenient`, `Class.isAssignableFrom`, `DateFormat.parse`, `Streams.parse`, `Excluder` fields).
Judgement calls: deprecated constructors (`JsonElement()`, `JsonNull()`, `JsonParser()`) are excluded from the
defect class, because subclasses call `JsonElement()` implicitly; the prompt says so.
