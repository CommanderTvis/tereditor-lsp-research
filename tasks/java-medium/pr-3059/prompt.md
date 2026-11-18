# JsonPrimitive with LazilyParsedNumber integers breaks contract for hashCode()

While most types maintain consistency between `equals()` and `hashCode()` after string serialization and parsing (`JsonElement#toString()` + `JsonParser#parse(String)`, integers do not. `equals()` returns true, but the hash codes are different.

```
  public void testEqualsIntegerAndLazilyParsedInteger() {
    MoreAsserts.assertEqualsAndHashCode(new JsonPrimitive(42), new JsonPrimitive(new LazilyParsedNumber("42")));
  }
```
