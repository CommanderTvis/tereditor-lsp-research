# JsonReader / JsonTreeReader.promoteNameToValue() causes incorrect JSON path

The internal method `JsonReaderInternalAccess.promoteNameToValue(JsonReader)` which is used before the key of a `Map<K,V>` is read causes an incorrect JSON path because after the name has been read as value, the JSON path is not updated.

For example:
```java
String malformedJson = "{\"name\":\"value";
try {
    new Gson().fromJson(malformedJson, new TypeToken<Map<String, String>>() {}.getType());
} catch (JsonSyntaxException exception) {
    // Incorrect: Path is missing name
    // Unterminated string at line 1 column 15 path $.
    System.out.println(exception.getCause().getMessage());
}

JsonReader jsonReader = new JsonReader(new StringReader(malformedJson));
jsonReader.beginObject();
jsonReader.nextName();
try {
    jsonReader.nextString();
} catch (MalformedJsonException exception) {
    // Correct: Path includes name
    // Unterminated string at line 1 column 15 path $.name
    System.out.println(exception.getMessage());
}
```
