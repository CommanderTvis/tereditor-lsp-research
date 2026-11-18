In `ProblemLogLevel` (`runtime/src/main/java/io/quarkiverse/httpproblem/postprocessing/ProblemLogLevel.java`) the
overload that logs a problem together with its cause is declared as `log(Logger logger, String message, Throwable cause)`.
Everywhere else in the project, and in the logging API it wraps, the cause comes before the message. Change the parameter
order of that overload to `log(Logger logger, Throwable cause, String message)`.

The change applies to the abstract declaration, to every constant of the enum that overrides it, and to every caller in
every module. The two-argument overload `log(Logger logger, String message)` keeps its signature. Behaviour does not
change: the same level checks and the same messages are logged.

The project must still build and the existing tests must pass.
