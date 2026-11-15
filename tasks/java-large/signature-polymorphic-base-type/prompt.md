`AnnotationIntrospector.findPolymorphicBaseType(MapperConfig<?> config, AnnotatedClass ac, JsonTypeInfo.Value typeInfo,
JavaType assumedBaseType)` never uses its `typeInfo` argument, and neither does any implementation. Remove that
parameter: the method becomes `findPolymorphicBaseType(MapperConfig<?> config, AnnotatedClass ac, JavaType
assumedBaseType)` in `AnnotationIntrospector` and in every class that overrides it, main code and tests, and every
caller passes one argument less. Do not keep the four-argument variant, and drop the parameter from the Javadoc.
Behaviour must not change.
