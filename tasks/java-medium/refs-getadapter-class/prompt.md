`com.google.gson.Gson` has two overloads of `getAdapter`: one taking a `TypeToken<T>` and one taking a `Class<T>`. I
need every call of the `Class<T>` overload in the `gson/` module (both `gson/src/main` and `gson/src/test`), and only
that overload: calls of the `TypeToken` overload, of other classes' `getAdapter` methods, comments and Javadoc do not
count, and neither does the declaration itself.

Write the result to `ANSWER.txt` in the repository root, one call per line as `relative/path.java:LINE` (1-based line
of the call; if a call spans several lines, the line where `getAdapter` appears), for example
`gson/src/main/java/com/google/gson/Foo.java:12`.
