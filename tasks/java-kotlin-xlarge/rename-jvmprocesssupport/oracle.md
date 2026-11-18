# Oracle: rename-jvmprocesssupport

`gold.patch` renames the class in both of its copies (the base source set and the multi-release `java9` source set), the
two test classes that exercise them and the one main-code user (`ExecHandleRunner`), by a script that rewrites the whole word
only in files of the declaring package or that name its fully qualified class; the result is checked by the build:
`:process-services-base:test` and `:process-services-base:java9Test` compile and pass with the patch applied, together with
the held-out test in `hidden/`. No language server is involved. Judgement calls: the new name was chosen by hand; test
classes called `JvmProcessSupportTest` and `JvmProcessSupportJava9Test` keep their names (the prompt says so).
