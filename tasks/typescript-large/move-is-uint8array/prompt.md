We are collecting our runtime type guards in their own directory. Move the function `isUint8Array` out of
`packages/typeorm/src/util/Uint8ArrayUtils.ts` into a new module `packages/typeorm/src/util/guards/isUint8Array.ts`,
and update every file that uses it (library code and tests) to import it from there. After the change
`isUint8Array` must be declared only in the new module; `Uint8ArrayUtils.ts` must neither declare nor re-export it.
The other helpers stay where they are. The package must compile and the tests must pass.
