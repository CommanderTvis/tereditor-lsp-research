I need every place in the platform's library code (`src/`; not `tests/`, not `vendor/`) where the method `getTaxState()` declared in `Shopware\Core\Framework\Context` (`src/Core/Framework/Context.php`) is called.

Do not include its declaration, comments, strings or documentation, or calls of any other method named `getTaxState()` (the ones on `SalesChannelContext` and `BaseSalesChannelContext`, and `TaxDetector::getTaxState()`).

Write the result to `ANSWER.txt` in the repository root, one location per line as `relative/path.php:LINE` (the 1-based line of the call), for example `src/Foo.php:12`.
