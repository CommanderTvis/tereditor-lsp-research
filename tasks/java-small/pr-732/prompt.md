# Add trailing newline to methods if necessary

When `MethodSpec.addCode()` is used as opposed to `addStatement()`, it's often possible to end up with methods that have no trailing newline and thus look like:

```java
void foo() {
  doThing();
  doThing2();}
```

This can easily happen when the body of a method is composed as a `List<CodeBlock>` and then passed to `CodeBlock.join("\n", statements)` (and happens within Dagger often. It's coming up now that we've turned off formatting by default).

This is easily avoidable by using `CodeBlock.join("", statements)` and ensuring that each statement uses `CodeBlock.builder().addStatement().build()` instead of `CodeBlock.of()`, or by using `CodeBlock.join("", "\n", "\n", statements) to add a suffix newline. But both of these are awkward and easy to forget.

I think it should be relatively easy, with some possible hackery in `LineWrapper` to retain whether the last character is a `;` and to propagate that information so that `MethodSpec.emit()` can emit an extra newline if necessary. 
