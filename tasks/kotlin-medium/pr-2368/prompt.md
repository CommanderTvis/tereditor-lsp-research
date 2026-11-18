# No TypeParameter found for index T

**Describe the bug**
After upgrade from `1.18.1` version to `2.0.0` I started to face an issue `No TypeParameter found for index T`

**To Reproduce**
I had next code:
```kotlin
(this.declaration as KSClassDeclaration).getAllSuperTypes().any { it.toClassName() == ITERABLE }
```
I started to face next issue:
```
KSType 'Comparable<String>' has type arguments, which are not supported for ClassName conversion. Use KSType.toTypeName().
```
After switching on `toTypeName` I face `No TypeParameter found for index T`
```kotlin
(this.declaration as KSClassDeclaration).getAllSuperTypes().any { it.toTypeName() == ITERABLE }
```

**Expected behavior**
`toTypeName` should work for wide generic classes.

**Additional context**
Maybe I don't see the reason why `toTypeName` requests `TypeParameterResolver`.
