# `NullPointerException` ("Null 'propertyType' passed") deserializing raw `Map.Entry` with a `Shape.POJO` config override

### Search before asking

- [x] I searched in the [issues](https://github.com/FasterXML/jackson-databind/issues) and found nothing similar.

### Describe the bug

With the 3.1 `Shape.POJO` support for `Map.Entry` deserialization (#1419) enabled through a config override, reading a raw `Map.Entry` fails with a raw NPE:

```
java.lang.NullPointerException: Null 'propertyType' passed
	at java.base/java.util.Objects.requireNonNull(Objects.java:235)
	at tools.jackson.databind.deser.DeserializerCache.findValueDeserializer(DeserializerCache.java:159)
	at tools.jackson.databind.DeserializationContext.findContextualValueDeserializer(DeserializationContext.java:747)
	at tools.jackson.databind.deser.jdk.MapEntryDeserializer$POJOWrappedDeserializer._createContextual2(MapEntryDeserializer.java:437)
	at tools.jackson.databind.deser.jdk.MapEntryDeserializer$POJOWrappedDeserializer.createContextual(MapEntryDeserializer.java:412)
	...
```

Cause: `POJOWrappedDeserializer._createContextual2()` uses `_valueType.containedTypeOrUnknown(0)` for the key (`MapEntryDeserializer.java:422`) but `_valueType.containedType(1)` for the value (`:435`). For a raw `Map.Entry`, the second call returns `null`. `constructAsPOJO()` (`:125-129`) also skips the "Missing generic type information" check that the natural-shape constructor does (`:60-62`).

With the default shape, the same raw type fails with `InvalidDefinitionException: Missing generic type information for [simple type, class java.util.Map$Entry]`. With `@JsonFormat(shape = POJO)` on a raw `Map.Entry` property, it fails with the same `InvalidDefinitionException`, because the non-contextual default deserializer is built first. So only the type-level config override (or a mix-in) reaches the NPE.

### Version Information

3.x (reproduced on 3.3.0-SNAPSHOT `4f153f0`; the code is unchanged at `33550e9`) and 3.2.4. 2.x does not have `Shape.POJO` deserialization for `Map.Entry`.

### Reproduction

```java
JsonMapper mapper = JsonMapper.builder()
        .withConfigOverride(Map.Entry.class,
                o -> o.setFormat(JsonFormat.Value.forShape(JsonFormat.Shape.POJO)))
        .build();

mapper.readValue("{\"key\":\"a\",\"value\":\"b\"}",
        new TypeReference<Map.Entry<String, String>>() { });   // a=b
mapper.readValue("{\"key\":\"a\",\"value\":\"b\"}", Map.Entry.class);
// NullPointerException: Null 'propertyType' passed
```

### Expected behavior

Either `a=b` with `Object` key/value types, consistent with how the key type is already handled, or an `InvalidDefinitionException` as with the default shape. The NPE should not happen. Using `containedTypeOrUnknown(1)` on line 435 gives the first option. With that change, the full 3.x test suite passes.

### Additional context

This issue was found by an LLM-Enhanced Static Analysis Engine and verified manually.
