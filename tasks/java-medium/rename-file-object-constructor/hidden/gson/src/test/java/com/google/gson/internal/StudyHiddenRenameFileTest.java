package com.google.gson.internal;

import static com.google.common.truth.Truth.assertThat;
import static org.junit.Assert.assertThrows;

import org.junit.Test;

public class StudyHiddenRenameFileTest {
  @Test
  public void interfaceHasItsNewNameAndTheOldOneIsGone() throws Exception {
    Class<?> c = Class.forName("com.google.gson.internal.ObjectFactory");
    assertThat(c.isInterface()).isTrue();
    assertThat(c.getMethod("construct")).isNotNull();
    assertThrows(ClassNotFoundException.class, () -> Class.forName("com.google.gson.internal.ObjectConstructor"));
  }
}
