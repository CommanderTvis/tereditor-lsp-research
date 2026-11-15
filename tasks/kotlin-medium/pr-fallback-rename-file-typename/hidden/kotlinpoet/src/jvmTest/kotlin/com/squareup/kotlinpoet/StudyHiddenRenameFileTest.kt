package com.squareup.kotlinpoet

import assertk.assertThat
import assertk.assertions.isEqualTo
import assertk.assertions.isTrue
import kotlin.test.Test

class StudyHiddenRenameFileTest {
  @Test fun facadeFollowsTheFileName() {
    val facade = Class.forName("com.squareup.kotlinpoet.TypeNameFactoriesKt")
    val get = facade.getMethod("get", java.lang.reflect.Type::class.java)
    assertThat(get.invoke(null, String::class.java)).isEqualTo(String::class.asTypeName())
    assertThat(runCatching { Class.forName("com.squareup.kotlinpoet.TypeNames") }.isFailure).isTrue()
  }
}
