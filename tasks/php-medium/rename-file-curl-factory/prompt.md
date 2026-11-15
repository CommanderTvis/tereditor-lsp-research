Rename the class `GuzzleHttp\Handler\CurlFactory` to `CurlHandleFactory`, which also renames its file to
`src/Handler/CurlHandleFactory.php` (the package uses PSR-4 autoloading). Update every reference in the library and the
tests. Do not keep the old name as an alias. `CurlFactoryInterface` is a separate type and keeps its name. Renaming test
files and updating comments or documentation is optional.
