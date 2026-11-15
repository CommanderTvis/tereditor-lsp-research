# Oracle: files with TS4111 under noPropertyAccessFromIndexSignature

Derived from the TypeScript compiler, not a language server, at the pinned commit, with the project's own
typescript (Version 6.0.3) and dependencies installed from its lockfile:

    tsc -p tsconfig.spec.json --noPropertyAccessFromIndexSignature   # 33 TS4111 errors in 12 non-test files

Without the option the project type-checks cleanly. Of the 10 listed files, the 5 in oracle.txt report TS4111
(render.ts lines 521, 734, 745, 750; dom/jsx-dev-runtime.ts 19; dom/index.ts 48, 53, 54, 70; jsx-dev-runtime.ts 21;
accept.ts 226); the other 5 report none. Judgement calls: none.
