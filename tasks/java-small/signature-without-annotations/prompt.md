`TypeName.withoutAnnotations()` only removes the type annotations of the outermost type: for
`List<@A String>` or `@A String[]` the inner annotations survive, and there is no way to get a fully
annotation-free type.

Replace it with `withoutAnnotations(boolean deep)` on `TypeName` and every subclass that overrides it (no
no-argument variant should remain). With `deep == false` the result must be exactly what `withoutAnnotations()`
returns today. With `deep == true` the annotations of the types the type is made of are removed too, recursively:
array component types, type arguments of parameterized types and their enclosing parameterized types, and wildcard
bounds. The declared bounds of a type variable are kept as they are in both cases. Update all existing callers so
that their behaviour does not change.
