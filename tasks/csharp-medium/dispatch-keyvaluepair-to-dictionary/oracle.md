# Oracle: which MapExpression runs for KeyValuePair<int, string> -> Dictionary<string, object>

Derived without a language server, by running the code: a throwaway xunit test in the unit test project, at the pinned
commit, built with the .NET 10 SDK:

    var config = new MapperConfiguration(cfg => { }, NullLoggerFactory.Instance);
    config.Internal().FindMapper(new TypePair(typeof(KeyValuePair<int, string>), typeof(Dictionary<string, object>)))
    // -> AutoMapper.Internal.Mappers.ToStringDictionaryMapper
    config.CreateMapper().Map<Dictionary<string, object>>(new KeyValuePair<int, string>(1, "a"))
    // -> { [Key, 1], [Value, a] }: the member dictionary ToStringDictionaryMapper.MapExpression builds

`MapperConfiguration.FindMapper` returns the first default mapper (MapperRegistry order) whose IsMatch accepts the
pair; the mapping plan then calls that mapper's MapExpression. ToStringDictionaryMapper.MapExpression is declared on
line 7 of src/AutoMapper/Mappers/ToStringDictionaryMapper.cs (expression-bodied, continued on line 8).

Judgement calls: none. Earlier mappers in the registry reject the pair: CollectionMapper (the source is not
enumerable), KeyValueMapper (the destination is not a KeyValuePair), ConstructorMapper (no Dictionary constructor
takes the pair), FromStringDictionaryMapper (the source is not a string-keyed dictionary).
