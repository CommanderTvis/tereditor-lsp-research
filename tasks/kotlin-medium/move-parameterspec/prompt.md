Move `ParameterSpec` into a package of its own: the file
`kotlinpoet/src/jvmMain/kotlin/com/squareup/kotlinpoet/ParameterSpec.kt` becomes
`kotlinpoet/src/jvmMain/kotlin/com/squareup/kotlinpoet/parameterspec/ParameterSpec.kt`, in package
`com.squareup.kotlinpoet.parameterspec`, with everything the file declares. Do not change what the declarations do.

Update every module, main code and tests (Kotlin and Java), so the whole build compiles and all tests pass. Do not
leave a type alias or any other forwarding declaration in the old package. Updating the public API dump
(`kotlinpoet/api/kotlinpoet.api`) and the documentation is welcome but not required.
