Our post-processing hook `ProblemPostProcessor` is the public extension point users implement to change a problem before it
is written, but it sits in the `io.quarkiverse.httpproblem.postprocessing` package next to the internal registry and
logging classes. It belongs next to `HttpProblem` and `ExceptionMapperBase`, which it is used with.

Move the interface `ProblemPostProcessor` (`runtime/src/main/java/io/quarkiverse/httpproblem/postprocessing/ProblemPostProcessor.java`)
into the package `io.quarkiverse.httpproblem`: its source file goes to `runtime/src/main/java/io/quarkiverse/httpproblem/`,
its `package` declaration changes, and everything that refers to it must follow, in every module: imports, classes
of the old package that used it without an import, the tests, the integration tests, Javadoc references and any
documentation or sample code that names its package. Nothing else moves, and no copy or alias is left in the old package.

The project must still build and the existing tests must pass.
