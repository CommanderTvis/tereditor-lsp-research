package tools.jackson.databind.ser;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.json.JsonMapper;

class StudyHiddenMoveTest
{
    static class Bean { public int x = 1; }

    @Test
    void beanSerializerBaseLivesInTheSerPackage() throws Exception
    {
        assertEquals("tools.jackson.databind.ser.BeanSerializerBase", BeanSerializerBase.class.getName());
        ObjectMapper mapper = JsonMapper.builder().build();
        assertTrue(BeanSerializerBase.class.isAssignableFrom(BeanSerializer.class));
        assertEquals("{\"x\":1}", mapper.writeValueAsString(new Bean()));
    }
}
