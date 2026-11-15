We want to be able to register a shared service with a plain `add()` call. Change the signature of `add()` in
`League\Container\DefinitionContainerInterface` and in the `Container` that implements it to

    add(string $id, mixed $concrete = null, bool $shared = false, bool $overwrite = false): DefinitionInterface

When `$shared` is true, `add()` must behave exactly like `addShared()` (with the same overwrite behaviour); otherwise it
behaves as before. Update every caller in the library and the tests that relies on the old parameter order. Only the
container's `add()` changes: other `add()` methods in the package (for example on the definition aggregate) keep
their signatures. Updating documentation files is optional.
