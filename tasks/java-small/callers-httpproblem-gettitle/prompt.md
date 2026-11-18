We are about to change what `HttpProblem.getTitle()` returns (`runtime/src/main/java/io/quarkiverse/httpproblem/HttpProblem.java`)
and need to know everything in the production code that can be affected.

List every method and constructor in the production code, in all modules (the `src/main` source sets; test code does not
count), that calls `HttpProblem.getTitle()` directly or reaches it through any chain of calls between production
methods. A call through an interface or a superclass type counts for every implementation or override in this
repository that it can dispatch to. Calls to other methods that merely have the same name (for example `getTitle()` on
types from other libraries) do not count, and neither does `getTitle()` itself.

Write the result to `ANSWER.txt` in the repository root, one method per line, as the fully qualified name of the class
that declares the method, `#`, and the method name, for example `com.example.Foo#bar`. A constructor is written
`com.example.Foo#<init>`. Several overloads of one method name share a single line. Lambdas and anonymous code count
for the method that contains them.
