package com.squareup.javapoet;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.junit.Assert.assertTrue;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import org.junit.Test;

public class StudyHiddenMoveTest {
  @Test
  public void utilLivesInTheInternalPackageOnly() throws Exception {
    Class<?> util = Class.forName("com.squareup.javapoet.internal.Util");
    assertTrue(Modifier.isPublic(util.getModifiers()));
    Method m = util.getMethod("characterLiteralWithoutSingleQuotes", char.class);
    assertTrue(Modifier.isPublic(m.getModifiers()) && Modifier.isStatic(m.getModifiers()));
    assertEquals("\\n", m.invoke(null, '\n'));
    assertThrows(ClassNotFoundException.class, () -> Class.forName("com.squareup.javapoet.Util"));
  }

  // JUnit 4.12 has no assertThrows.
  interface Call { void run() throws Exception; }

  private static void assertThrows(Class<? extends Exception> expected, Call call) {
    try {
      call.run();
    } catch (Exception e) {
      if (expected.isInstance(e)) return;
      throw new AssertionError("expected " + expected.getName() + " but got " + e, e);
    }
    fail("expected " + expected.getName());
  }
}
