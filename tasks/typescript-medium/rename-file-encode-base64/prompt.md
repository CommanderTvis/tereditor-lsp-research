The module `src/utils/encode.ts` only contains the base64 and base64url helpers, so rename it to
`src/utils/base64.ts`, and rename its test file `src/utils/encode.test.ts` to `src/utils/base64.test.ts`. Update
every import of the module across the code base and tests, and the entry for it in `jsr.json` (both the export key,
which becomes `./utils/base64`, and the path). Do not leave a file at the old path or a module that re-exports the
new one under the old name. The type check and the tests must pass.
