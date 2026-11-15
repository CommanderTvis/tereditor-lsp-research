package com.squareup.kotlinpoet.parameterspec

import assertk.assertThat
import assertk.assertions.contains
import assertk.assertions.isEqualTo
import assertk.assertions.isTrue
import com.squareup.kotlinpoet.FunSpec
import com.squareup.kotlinpoet.INT
import kotlin.test.Test

class StudyHiddenMoveTest {
  @Test fun parameterSpecLivesInItsOwnPackage() {
    val p = ParameterSpec.builder("count", INT).defaultValue("%L", 1).build()
    assertThat(ParameterSpec::class.java.name).isEqualTo("com.squareup.kotlinpoet.parameterspec.ParameterSpec")
    val f = FunSpec.builder("f").addParameter(p).addParameter("b", INT).build()
    assertThat(f.parameters.map { it.name }).isEqualTo(listOf("count", "b"))
    assertThat(f.toString()).contains("count: kotlin.Int = 1")
    assertThat(runCatching { Class.forName("com.squareup.kotlinpoet.ParameterSpec") }.isFailure).isTrue()
  }
}
