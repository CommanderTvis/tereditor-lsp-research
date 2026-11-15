package com.squareup.javapoet;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.junit.Test;

public class StudyHiddenSignatureTest {
  private static final AnnotationSpec A = AnnotationSpec.builder(ClassName.get("com.example", "A")).build();
  private static final TypeName STRING = ClassName.get(String.class).annotated(A);

  @Test public void noArgumentVariantIsGone() {
    assertThrows(NoSuchMethodException.class, () -> TypeName.class.getMethod("withoutAnnotations"));
    for (Class<?> c : new Class<?>[] {TypeName.class, ClassName.class, ArrayTypeName.class,
        ParameterizedTypeName.class, TypeVariableName.class, WildcardTypeName.class}) {
      assertThrows(NoSuchMethodException.class, () -> c.getDeclaredMethod("withoutAnnotations"));
    }
  }

  @Test public void parameterizedType() {
    TypeName t = ParameterizedTypeName.get(ClassName.get(List.class), STRING).annotated(A);
    assertEquals("java.util.List<java.lang. @com.example.A String>", t.withoutAnnotations(false).toString());
    assertEquals("java.util.List<java.lang.String>", t.withoutAnnotations(true).toString());
  }

  @Test public void arrayType() {
    TypeName t = ArrayTypeName.of(STRING).annotated(A);
    assertEquals("java.lang. @com.example.A String[]", t.withoutAnnotations(false).toString());
    assertEquals("java.lang.String[]", t.withoutAnnotations(true).toString());
  }

  @Test public void wildcardType() {
    TypeName t = WildcardTypeName.subtypeOf(STRING).annotated(A);
    assertEquals("? extends java.lang. @com.example.A String", t.withoutAnnotations(false).toString());
    assertEquals("? extends java.lang.String", t.withoutAnnotations(true).toString());
  }

  @Test public void nestedClassAndPrimitive() {
    ClassName entry = ClassName.get(Map.class).annotated(Collections.singletonList(A))
        .nestedClass("Entry").annotated(Collections.singletonList(A));
    assertEquals(TypeName.get(Map.Entry.class), entry.withoutAnnotations(false));
    assertEquals(TypeName.get(Map.Entry.class), entry.withoutAnnotations(true));
    assertEquals(TypeName.INT, TypeName.INT.annotated(A).withoutAnnotations(true));
  }

  @Test public void typeVariableKeepsItsBounds() {
    TypeVariableName t = TypeVariableName.get("T", STRING);
    TypeName stripped = t.annotated(A).withoutAnnotations(true);
    assertEquals("T", stripped.toString());
    assertEquals(t.bounds, ((TypeVariableName) stripped).bounds);
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
