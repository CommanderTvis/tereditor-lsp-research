package com.squareup.kotlinpoet

import assertk.assertThat
import assertk.assertions.contains
import assertk.assertions.isEqualTo
import assertk.assertions.isFalse
import assertk.assertions.isTrue
import kotlin.test.Test

class StudyHiddenRenameTest {
  @Test fun makeMutableReplacesMutable() {
    val v = PropertySpec.builder("count", Int::class).makeMutable().initializer("0").build()
    assertThat(v.mutable).isTrue()
    assertThat(v.toString()).contains("var count: kotlin.Int = 0")
    val p = PropertySpec.builder("count", Int::class).makeMutable(false).build()
    assertThat(p.mutable).isFalse()
    assertThat(PropertySpec.Builder::class.java.methods.none { it.name == "mutable" }).isTrue()
  }
}
