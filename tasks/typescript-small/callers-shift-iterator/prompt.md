The internal helper `shiftIterator` in `src/utils.ts` is about to change, and I need to know which parts of the
public API can end up running it. List every public entry point that reaches `shiftIterator` through a chain of
calls.

Public entry points are the functions exported by the package entry `src/index.ts` (directly or through its
`export *` re-exports) and the methods of the exported `Struct` class, including its constructor. Count a call like
this:

- A function calls another when its body calls it by name, including inside closures, callbacks and object members
  defined within that body (for example a `validator` or `coercer` function created inside it).
- `new Struct(...)` is a call of the `Struct` constructor, and `someStruct.validate(...)` (or `.assert`, `.create`,
  `.is`, `.mask`) on a `Struct` value is a call of that `Struct` method.
- Calls through functions stored on a struct and invoked indirectly (`struct.validator(...)`, `struct.refiner(...)`,
  `struct.coercer(...)`, `struct.entries(...)`) do not count, and neither do calls in tests.

Write the result to `ANSWER.txt` in the repository root, one entry point per line: an exported function by its
exported name (for example `string`), a `Struct` method as `Struct.methodName` (for example `Struct.constructor`).
Do not list `shiftIterator` itself or any function that is not a public entry point.
