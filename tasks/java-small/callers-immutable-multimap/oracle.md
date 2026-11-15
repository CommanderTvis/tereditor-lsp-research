# Oracle: public API methods that reach Util.immutableMultimap

Derived from bytecode, not a language server: `derive-oracle.sh` compiles `src/main/java` with javac 21 (through
Maven, Error Prone dropped as in `check.sh`), dumps every class with `javap -c -p -s`, and `callgraph.py` walks the
call graph backwards from `Util.immutableMultimap`.

Call graph rules (callgraph.py): every `invokevirtual`, `invokespecial`, `invokestatic` and `invokeinterface` is an
edge; a call on a JavaPoet type reaches the method it resolves to and every override declared in a JavaPoet subtype
(class hierarchy analysis); calls on JDK types are not followed into JavaPoet code; a lambda body `lambda$m$N` is
attributed to the methods named `m` of its class. Entry points: public, non-synthetic methods (not constructors) of
public classes whose enclosing classes are all public, named `package.Outer.Nested.method`, overloads merged.

Result: 7 methods. Only one call site exists (`AnnotationSpec`'s private constructor, reached only from
`AnnotationSpec.Builder.build`); every entry point was checked by reading the source.

Judgement calls and limits:
- Method references (`invokedynamic` method handles such as `CodeBlockJoiner::add` in `CodeBlock.joining`) are not
  edges in callgraph.py. The main code has 6 of them (`Method::getName` in `AnnotationSpec`, `CodeBlockJoiner::add`,
  `::merge`, `::join` in `CodeBlock`); none of them leads to `AnnotationSpec.Builder.build`, so the answer is not
  affected.
- Calls made only by JDK code (`toString()` through `String.format`, `Appendable.append`) do not count; the prompt
  says so.
