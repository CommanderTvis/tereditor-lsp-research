package com.google.gson;

import static com.google.common.truth.Truth.assertThat;

import java.lang.reflect.Method;
import java.util.Arrays;
import org.junit.Test;

public class StudyHiddenRenameTest {
  @Test
  public void newNameExistsAndOldNameIsGone() throws Exception {
    Method m = GsonBuilder.class.getMethod("serializeSpecialFloatingPointValuesV2");
    assertThat(m.getReturnType()).isEqualTo(GsonBuilder.class);
    assertThat(
            Arrays.stream(GsonBuilder.class.getMethods())
                .noneMatch(x -> x.getName().equals("serializeSpecialFloatingPointValues")))
        .isTrue();
    // The package-private fields keep their names: only the method is renamed.
    assertThat(GsonBuilder.class.getDeclaredField("serializeSpecialFloatingPointValues")).isNotNull();
    assertThat(Gson.class.getDeclaredField("serializeSpecialFloatingPointValues")).isNotNull();
  }
}
