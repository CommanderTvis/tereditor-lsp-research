Rename the generic interface `IRequestHandler<TRequest, TResponse>` (the request handler that returns a response,
declared in `src/MediatR/IRequestHandler.cs`) to `IQueryHandler<TRequest, TResponse>`, everywhere it is declared,
implemented or referenced: the library, the tests, the benchmarks and the samples, including open generic forms such
as `typeof(...<,>)` and XML documentation references.

The one-parameter interface `IRequestHandler<TRequest>` (the handler for requests without a response) keeps its name
and must not change. Do not keep the old two-parameter name as an alias. The solution must build and the existing
tests must pass. Updating Markdown documentation is optional.
