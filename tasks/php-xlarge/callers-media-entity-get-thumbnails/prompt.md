I need to know which methods of the platform's library code (`src/`; not `tests/`, not `vendor/`) call the method `getThumbnails()` declared in `Shopware\Core\Content\Media\MediaEntity` (`src/Core/Content/Media/MediaEntity.php`) directly in their own body (not through another method that calls it).

Do not include calls of any other method named `getThumbnails()` on unrelated classes, and do not include `getThumbnails()` itself.

Write the result to `ANSWER.txt` in the repository root, one fully qualified method per line as `Namespace\Class::method` (no leading backslash, no parameters), for example `Shopware\Core\Foo\Bar::baz`. A method that calls it several times is listed once.
