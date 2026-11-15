#!/bin/bash
# Reference solution of java-large/signature-polymorphic-base-type, run at the root of the pinned snapshot.
set -e
fs=$(git grep -l findPolymorphicBaseType -- src)
perl -0pi -e '
  s/(findPolymorphicBaseType\(MapperConfig<\?> config,\s*AnnotatedClass ac,) JsonTypeInfo\.Value typeInfo,/$1/g;
  s/findPolymorphicBaseType\(config, ac, typeInfo, assumedBaseType\)/findPolymorphicBaseType(config, ac, assumedBaseType)/g;
  s/findPolymorphicBaseType\(config, annotatedClass, typeInfo, baseType\)/findPolymorphicBaseType(config, annotatedClass, baseType)/g;
  s/findPolymorphicBaseType\(null, null, null, null\)/findPolymorphicBaseType(null, null, null)/g;
  s/findPolymorphicBaseType\(config, ac, null, /findPolymorphicBaseType(config, ac, /g;
  s/     \* \@param typeInfo Polymorphic type info introspected \(usually via \{\@link #findPolymorphicTypeInfo\}\)\n(     \* \@param assumedBaseType)/$1/;
' $fs
