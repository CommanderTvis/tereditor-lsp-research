# Allow skipping null values for properties handled by `@JsonAnySetter`

### Discussed in https://github.com/FasterXML/jackson-databind/discussions/6169

<div type='discussions-op-text'>

<sup>Originally posted by **margarita-sk** August 20, 2026</sup>
When configuring JsonMapper with null handling:

```
        .changeDefaultNullHandling(v -> v.withValueNulls(Nulls.SKIP))
        .changeDefaultNullHandling(v -> v.withContentNulls(Nulls.SKIP))
```
the configuration appears to have no effect on properties handled by @JsonAnySetter.

### Reproduction
```
class Jackson3Test {

    @Test
    void testSkipNullValuesInJsonAnySetter() {
        JsonMapper jsonMapper = JsonMapper.builder()
                .changeDefaultNullHandling(v -> v.withValueNulls(Nulls.SKIP))
                .changeDefaultNullHandling(v -> v.withContentNulls(Nulls.SKIP))
                .build();

        String json = """
                {
                "non_null_property": "test",
                "null_property": null
                }
                """;
        TestPojo input = jsonMapper.readValue(json, TestPojo.class);

        Assertions.assertEquals(1, input.getDynamicProperties()
                .size()); // is failed, but expected to pass because of the default null handling configuration
    }
    
    static class TestPojo {

        private final Map<String, JsonNode> dynamicProperties = new HashMap<>();

        @JsonAnySetter
        public void setDynamicProperties(String key, JsonNode value) {
            this.dynamicProperties.put(key, value);
        }

        public Map<String, JsonNode> getDynamicProperties() {
            return this.dynamicProperties;
        }

    }

}
```

### Actual behavior
The @JsonAnySetter method is invoked for both properties, including the property whose value is null.

### Expected behavior
With the mapper configured with:
```
        .changeDefaultNullHandling(v -> v.withValueNulls(Nulls.SKIP))
        .changeDefaultNullHandling(v -> v.withContentNulls(Nulls.SKIP))
```
I would expect the null_property value to be skipped and the @JsonAnySetter method not to be invoked for it.

### Question
Is the current behavior intentional for @JsonAnySetter?
If this is intentional, is there currently a recommended way to configure @JsonAnySetter to skip null values?
If it is not intentional, is support for applying Nulls.SKIP to @JsonAnySetter planned for Jackson 3?</div>
