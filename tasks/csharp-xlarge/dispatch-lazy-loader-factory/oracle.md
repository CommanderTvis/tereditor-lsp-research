# Oracle: implementation registered for ILazyLoaderFactory

Not derived from a language server. `TryAddCoreServices` in src/EFCore/Infrastructure/EntityFrameworkServicesBuilder.cs line 296
reads `TryAdd<ILazyLoaderFactory, LazyLoaderFactory>();`; `LazyLoaderFactory` is declared once, in
src/EFCore/Infrastructure/Internal/LazyLoaderFactory.cs, namespace `Microsoft.EntityFrameworkCore.Infrastructure.Internal`. No other
class implements the interface in src/EFCore. Provider packages do not replace this registration (checked: no
`ILazyLoaderFactory` registration under src/EFCore.*).
