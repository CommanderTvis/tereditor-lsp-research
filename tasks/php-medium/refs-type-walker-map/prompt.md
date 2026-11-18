I need every place in the library code (`src/`; not `tests/`, not `vendor/`) where the method `map()` declared in `Dedoc\Scramble\Support\Type\TypeWalker` (`src/Support/Type/TypeWalker.php`) is called.

Do not include its declaration, comments, strings or documentation, or calls of any other method named `map()` (the one on `ArgumentTypeBag` and its implementations, Laravel collection `map()` calls, `array_map`, and so on).

Write the result to `ANSWER.txt` in the repository root, one location per line as `relative/path.php:LINE` (the 1-based line of the call), for example `src/Foo.php:12`.
