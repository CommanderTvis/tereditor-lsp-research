Move the function `writeFromReadableStreamDefaultReader` out of `src/utils.ts` into a new module
`src/internal/writeFromReadableStreamDefaultReader.ts`, and update every file that uses it to import it from its new
location, including the tests. After the change `writeFromReadableStreamDefaultReader` must be declared only in
`src/internal/writeFromReadableStreamDefaultReader.ts`; do not re-export it from `src/utils.ts`. Comments that name
the function should still make sense. The public API of the package must not change, and the type checks and tests
must keep passing.
