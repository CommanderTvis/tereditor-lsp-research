Move the function `toFailures` out of `src/utils.ts` into a new module `src/internal/toFailures.ts`, and update
every file that uses it to import it from its new location. After the change `toFailures` must be declared only in
`src/internal/toFailures.ts`; do not re-export it from `src/utils.ts`. Private helpers that only `toFailures` needs
may move with it. The public API of the package must not change, and the type checks and tests must keep passing.
