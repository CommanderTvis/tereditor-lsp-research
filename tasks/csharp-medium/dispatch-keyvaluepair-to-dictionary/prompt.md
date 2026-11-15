In this repository's AutoMapper, take a configuration with no maps at all and map a key/value pair to a dictionary:

```csharp
var config = new MapperConfiguration(cfg => { }, NullLoggerFactory.Instance);
var result = config.CreateMapper().Map<Dictionary<string, object>>(new KeyValuePair<int, string>(1, "a"));
```

AutoMapper builds the mapping for this type pair by calling `MapExpression` on one of its built-in object mappers
(the `IObjectMapper` implementations it registers by default). Which `MapExpression` method runs for this call?

Write the answer to `ANSWER.txt` in the repository root as a single line `relative/path.cs:LINE`, where LINE is the
1-based line on which that `MapExpression` method is declared (the line with its name), for example
`src/AutoMapper/Foo.cs:12`.
