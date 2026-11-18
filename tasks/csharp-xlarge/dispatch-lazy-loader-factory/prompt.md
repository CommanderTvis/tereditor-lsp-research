Entity Framework Core resolves its services through dependency injection. When an application uses a `DbContext` with the default core service registration (`EntityFrameworkServicesBuilder.TryAddCoreServices`, `src/EFCore/Infrastructure/EntityFrameworkServicesBuilder.cs`), which concrete class is registered as the implementation of the interface `ILazyLoaderFactory`?

Write the fully qualified name of that class (namespace and class name, for example `Some.Namespace.SomeClass`) as the only line of `ANSWER.txt` at the repository root.
