`Util.immutableMultimap` in `src/main/java/com/squareup/javapoet/Util.java` is about to change behaviour, and I need
to know which parts of JavaPoet's public API can be affected. List every public method of a public class of JavaPoet
(nested public classes such as the builders included) from which a call to `Util.immutableMultimap` can be reached,
directly or through any chain of calls in JavaPoet's main code (`src/main/java`). Constructors are not part of the
answer, but calls that go through them count. A call through a JavaPoet supertype counts for every JavaPoet override
it can dispatch to; calls that happen only inside JDK code (for example `toString()` invoked by string formatting)
do not count.

Write the result to `ANSWER.txt` in the repository root, one method per line as its fully qualified name with nested
classes separated by dots and no parameter list, for example `com.squareup.javapoet.Foo.Builder.bar`. Overloads of
one method name are listed once.
