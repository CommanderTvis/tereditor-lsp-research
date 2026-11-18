# `@JsonFormat(shape = ARRAY)` builder with `@JsonCreator` silently loses buffered property if builder is immutable

With a `@JsonFormat(shape = ARRAY)` builder that has a `@JsonCreator`, a non-creator property that comes before the last creator property is silently lost if the builder is immutable. There is no error: the property keeps its default value.

This is the property-based counterpart of #6363.

## Reproduction

```java
@JsonDeserialize(builder = Value.Builder.class)
@JsonFormat(shape = JsonFormat.Shape.ARRAY)
static class Value {
    final int a, c;

    Value(int a, int c) {
        this.a = a;
        this.c = c;
    }

    @JsonPropertyOrder({ "a", "c" })
    @JsonFormat(shape = JsonFormat.Shape.ARRAY)
    static class Builder {
        final int a, c;

        @JsonCreator
        Builder(@JsonProperty("c") int c) {
            this(0, c);
        }

        private Builder(int a, int c) {
            this.a = a;
            this.c = c;
        }

        public Builder withA(int v) { return new Builder(v, c); }
        public Value build() { return new Value(a, c); }
    }
}

Value v = JsonMapper.builder().build().readValue("[5,6]", Value.class);
// expected: a=5, c=6
// actual:   a=0, c=6
```

The same input gives `a=5, c=6` if `withA()` mutates the builder and returns `this`. Both results are from `3.x` plus #6391.

## Likely cause

`BeanAsArrayBuilderDeserializer._deserializeUsingPropertyBased()` buffers `a` because the builder doesn't exist yet. `PropertyBasedCreator.build()` then applies buffered values with `pv.assign(ctxt, bean)` and always returns the original instance, so the new builder returned by `withA()` appears to be dropped. I confirmed the loss but did not trace each step in a debugger.

`PropertyBasedCreator.build()` is shared code, so other property-based builder paths may need checking too. Only the array-shaped path was tested.
