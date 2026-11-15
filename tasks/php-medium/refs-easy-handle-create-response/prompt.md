I need every place in this repository's PHP code (`src/` and `tests/`; not `vendor/`) where the method
`createResponse()` declared in `GuzzleHttp\Handler\EasyHandle` (`src/Handler/EasyHandle.php`) is called.

Do not include its declaration, comments, strings or documentation, or calls of any other method named
`createResponse()` (the private one in `StreamHandler`, the PSR-17 `ResponseFactoryInterface::createResponse()` and its
implementations, and so on).

Write the result to `ANSWER.txt` in the repository root, one location per line as `relative/path.php:LINE` (the 1-based
line of the call), for example `src/Foo.php:12`.
