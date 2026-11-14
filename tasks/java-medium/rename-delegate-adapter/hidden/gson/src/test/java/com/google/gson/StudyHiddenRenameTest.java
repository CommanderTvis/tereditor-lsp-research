package com.google.gson;

import static com.google.common.truth.Truth.assertThat;

import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Method;
import java.util.Arrays;
import org.junit.Test;

public class StudyHiddenRenameTest {
  @Test
  public void newNameExistsAndOldNameIsGone() throws Exception {
    Method m = Gson.class.getMethod("getNextAdapter", TypeAdapterFactory.class, TypeToken.class);
    assertThat(m).isNotNull();
    assertThat(Arrays.stream(Gson.class.getMethods()).noneMatch(x -> x.getName().equals("getDelegateAdapter"))).isTrue();
  }
}
