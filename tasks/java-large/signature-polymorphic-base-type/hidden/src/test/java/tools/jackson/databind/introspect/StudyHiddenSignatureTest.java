package tools.jackson.databind.introspect;

import java.lang.reflect.Method;
import java.util.Arrays;

import org.junit.jupiter.api.Test;

import tools.jackson.databind.AnnotationIntrospector;
import tools.jackson.databind.JavaType;
import tools.jackson.databind.cfg.MapperConfig;

import static org.junit.jupiter.api.Assertions.*;

public class StudyHiddenSignatureTest
{
    @Test
    public void typeInfoParameterIsGone() throws Exception
    {
        for (Class<?> c : new Class<?>[] { AnnotationIntrospector.class,
                AnnotationIntrospectorPair.class, JacksonAnnotationIntrospector.class }) {
            Method m = c.getDeclaredMethod("findPolymorphicBaseType",
                    MapperConfig.class, AnnotatedClass.class, JavaType.class);
            assertEquals(JavaType.class, m.getReturnType());
            long count = Arrays.stream(c.getDeclaredMethods())
                    .filter(x -> x.getName().equals("findPolymorphicBaseType")).count();
            assertEquals(1, count, c.getName());
        }
    }
}
