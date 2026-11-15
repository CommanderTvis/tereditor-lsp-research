# Oracle: implementations of MediatR.Pipeline.IRequestExceptionHandler`3

Derived without a language server, from the compiler's output: the solution (MediatR.sln at the pinned commit) was built
with the .NET 10 SDK, and every type of every project's assembly was read with System.Reflection.MetadataLoadContext
(metadata only, nothing executed). Kept: classes and structs (abstract included, compiler-generated types excluded)
whose base-type chain or interface set contains `IRequestExceptionHandler<,,>` in any constructed form; nested types
written `Outer.Inner`.

    dotnet build MediatR.sln -p:NuGetAudit=false -p:CheckEolTargetFramework=false
    typeinfo <the 13 project assemblies of MediatR.sln>      # FullName, base types, interfaces per type
    impls.py types.tsv 'MediatR.Pipeline.IRequestExceptionHandler`3'

Cross-checked by hand against the exhaustive text candidates `rg -n 'IRequestExceptionHandler<' -g '*.cs'`
(12 class declarations implement it directly) and the classes deriving from those (one:
`MediatR.Examples.ExceptionHandler.Overrides.ServerExceptionHandler : ExceptionHandler.ServerExceptionHandler`).

Judgement calls: none. `samples/MediatR.Examples.Windsor` is not in the solution (the prompt excludes it; it declares
no implementation anyway). Same simple names in different namespaces are separate answers
(`CommonExceptionHandler`, `ServerExceptionHandler` twice each; `PingPongExceptionHandlerForType` in two test classes).
