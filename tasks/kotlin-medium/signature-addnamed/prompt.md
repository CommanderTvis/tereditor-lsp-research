Swap the two parameters of `CodeBlock.Builder.addNamed` (in
`kotlinpoet/src/jvmMain/kotlin/com/squareup/kotlinpoet/CodeBlock.kt`) so the argument map comes first:
`addNamed(arguments: Map<String, *>, format: String)`. Keep the parameter names and the behaviour.

Update every caller in the repository so each still produces the same code. The `addNamedCode(format, args)`
functions of the specs are not part of this change and keep their current parameter order. Updating the public API
dump (`kotlinpoet/api/kotlinpoet.api`) and the documentation is welcome but not required.
