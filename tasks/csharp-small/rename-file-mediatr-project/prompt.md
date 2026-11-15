Rename the core library project `src/MediatR/MediatR.csproj` to `MediatR.Core`: its directory becomes
`src/MediatR.Core/` and its project file `src/MediatR.Core/MediatR.Core.csproj`, so the assembly it produces is
`MediatR.Core.dll`. Update everything that refers to the project by its path or name: the solution, the projects that
reference it, and the build scripts. C# namespaces stay as they are (`MediatR`), and no file should remain under
`src/MediatR/`. The solution must build and the existing tests must pass.
