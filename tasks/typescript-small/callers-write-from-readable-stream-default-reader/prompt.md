The internal helper `writeFromReadableStreamDefaultReader` in `src/utils.ts` is about to change, and I need to know
which parts of the public API can end up running it. List every public entry point that reaches it through a chain of
calls.

Public entry points are the functions exported by the package's entry modules: `src/index.ts` (`serve`,
`createAdaptorServer`, `getRequestListener`, `upgradeWebSocket`), `src/serve-static.ts` (`serveStatic`),
`src/conninfo.ts` (`getConnInfo`) and `src/early-hints.ts` (`earlyHints`). Count a call like this:

- A function calls another when its body calls it by name, including inside closures, callbacks and handlers defined
  within that body.
- `new SomeClass(...)` is a call of that class's constructor.
- Calls through values (methods invoked on an object, functions stored in a property or passed as an argument and
  invoked elsewhere) do not count, and neither do calls in tests.

Write the result to `ANSWER.txt` in the repository root, one entry point per line, by its exported name (for example
`serveStatic`). Do not list `writeFromReadableStreamDefaultReader` itself or any function that is not a public entry
point.
