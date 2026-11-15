List every class in this solution that implements the interface `IRequestExceptionHandler<TRequest, TResponse, TException>`
(declared in `src/MediatR/Pipeline/IRequestExceptionHandler.cs`), directly or indirectly: classes that implement any
constructed form of it, and classes that inherit from such a class, at any depth. Abstract classes count; interfaces
do not.

Consider the projects that are part of `MediatR.sln` (the library, the tests, the benchmarks and the samples in the
solution); `samples/MediatR.Examples.Windsor`, which is not in the solution, does not count.

Write the result to `ANSWER.txt` in the repository root, one class per line as its fully qualified name: namespace and
class name, with a nested class written as `Outer.Inner` and without generic parameters, for example
`MediatR.Tests.SomeTests.SomeHandler`.
