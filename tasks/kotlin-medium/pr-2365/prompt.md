# Expression function runaway indentation

**Describe the bug**

When using `withIndent` in an expression function, the emitted code does not unindent properly. Automatic wrapping then causes compilation to fail as deeply nested code gets squeezed against the margin.

**To Reproduce**

Unfortunately I don't have a simple example, but I do have a branch that reproduces the problem: https://github.com/andrewparmet/protokt/tree/demo-broken-indentation

To reproduce, run `./gradlew protokt-core-lite:build`. The issue manifests in the generated code file `descriptor.kt`.

Errors are like: `e: /Users/.../protokt/protokt-core-lite/build/generated-sources/main/protokt/com/toasttab/protokt/descriptor.kt: (8132, 176): Expecting a top level declaration`

**Expected behavior**

My overall goal is to generate expression functions whose bodies begin on the next line, like so:

```kotlin
fun foo() =
    "some very long expression " +
        "that stretches on for many lines"
```

And the source of this bug is in `MessageGenerator.kt`:
```kotlin
buildCodeBlock {
    add(
        "return \nother is %T &&\n".bindSpaces(),
        msg.className
    )
    withIndent {
        equalsLines(properties).forEach(::add)
        add("other.unknownFields == unknownFields".bindSpaces())
    }
}
```

If I remove `withIndent()` then the code generates ok, although it's not pretty.

Thanks!

**Additional Context**

Note that the code generator has a formatting pass that is disabled; it is found in `GeneratedCodeCleanup.kt`.
