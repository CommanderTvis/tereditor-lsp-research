Change the signature of `IValueResolver<TSource, TDestination, TDestMember>.Resolve` (declared in
`src/AutoMapper/Configuration/IMemberConfigurationExpression.cs`) so that the `ResolutionContext context` parameter
comes first:

```csharp
TDestMember Resolve(ResolutionContext context, TSource source, TDestination destination, TDestMember destMember);
```

Update every implementation in the repository (the library, the unit tests, the dependency-injection tests and the
test app) and the code in the library that invokes resolvers, so that custom value resolvers keep working exactly as
before. `IMemberValueResolver<TSource, TDestination, TSourceMember, TDestMember>.Resolve` keeps its current parameter
order. The solution must build and the existing tests must pass. Updating the Markdown documentation is optional.
