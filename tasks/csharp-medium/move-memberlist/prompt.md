Move the enum `MemberList` (today declared at the end of `src/AutoMapper/Configuration/IProfileExpression.cs`, in
namespace `AutoMapper`) into a new namespace `AutoMapper.Core`, in its own file `src/AutoMapper/Core/MemberList.cs`.
After the move it is declared in `AutoMapper.Core` only, with the same members and values. Update every place that
uses it (the library, the unit tests and the other projects of the solution) so the solution builds and the existing
tests pass. Do not leave a copy or alias in the old namespace.
