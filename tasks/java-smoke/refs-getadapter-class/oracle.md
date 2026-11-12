# Oracle: calls of Gson.getAdapter(Class<T>) in the gson module

Derived with javac, not a language server: `derive-oracle.sh`, run in the grade image (`--network none`).

1. Compile every `.java` under `gson/src/main/java`, `gson/src/test/java` and the module's generated sources, with the
   module's test-scope classpath: 0 errors.
2. Rename the `Class<T>` overload (Gson.java line 407 at the pinned commit) and compile again: 35 errors.
3. Each new error is a call that resolved to that overload; it is mapped to the line where `getAdapter(` appears (the
   error line or the nearest one above, for calls split over lines).

35 calls in 15 files. Calls of the `TypeToken` overload still compile after the rename, so they cannot appear.
Judgement calls: none; two calls on one line would count once (none observed).
