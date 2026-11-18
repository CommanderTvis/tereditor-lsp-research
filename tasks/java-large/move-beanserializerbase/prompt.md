`BeanSerializerBase` is the base class every standard bean serializer extends, and custom serializers are allowed to extend it too, but it sits in the `tools.jackson.databind.ser.bean` package next to the serializers that implement it. It belongs with the other serializer building blocks in `tools.jackson.databind.ser` (`BeanSerializer`, `BeanPropertyWriter`, `SerializerFactory`).

Move the abstract class `BeanSerializerBase` (`src/main/java/tools/jackson/databind/ser/bean/BeanSerializerBase.java`) into the package `tools.jackson.databind.ser`: its source file goes to `src/main/java/tools/jackson/databind/ser/`, its `package` declaration changes, and everything that refers to it must follow: imports, classes of the old package that used it without an import, the tests, and Javadoc references. Nothing else moves, and no copy or alias is left in the old package.

The project must still build and the existing tests must pass.
