package com.squareup.kotlinpoet

import assertk.assertThat
import assertk.assertions.contains
import assertk.assertions.isEqualTo
import kotlin.test.Test

class StudyHiddenSignatureTest {
  @Test fun addNamedTakesTheArgumentsFirst() {
    val block = CodeBlock.builder().addNamed(mapOf("food" to "tacos"), "I ate %food:L").build()
    assertThat(block.toString()).isEqualTo("I ate tacos")
  }

  @Test fun addNamedCodeKeepsItsOrder() {
    val f = FunSpec.builder("f").addNamedCode("val x = %x:L\n", mapOf("x" to 1)).build()
    assertThat(f.toString()).contains("val x = 1")
    val file = FileSpec.scriptBuilder("s").addNamedCode("println(%x:L)\n", mapOf("x" to 2)).build()
    assertThat(file.toString()).contains("println(2)")
  }
}
