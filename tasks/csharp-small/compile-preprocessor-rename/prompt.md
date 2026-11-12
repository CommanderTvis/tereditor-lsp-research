We renamed the method of the request pre-processor interface in `src/MediatR/Pipeline/IRequestPreProcessor.cs` from
`Process` to `PreProcess`, and only that file was changed. The solution no longer builds. Update the rest of the code
base (library, tests, samples and benchmarks in `MediatR.sln`) so that everything builds and the tests pass again.

Keep the new name and do not add an alias or a default implementation for the old one. The post-processor interface
(`IRequestPostProcessor`) is not part of this change and must keep its `Process` method.
