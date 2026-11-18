I need every class in the Laravel framework source (`src/`) that explicitly declares that it implements PHP's built-in `\Stringable` interface, that is, `Stringable` (the built-in one, not `Illuminate\Support\Stringable`, the fluent string class) is named in the `implements` clause of the class declaration itself.

Count only such classes: do not include subclasses that merely inherit the interface, classes that only define `__toString()` without naming `Stringable`, interfaces that extend `Stringable`, traits, enums, anonymous classes, or anything under `tests/`. A class that lists `Stringable` through an `use Stringable as Alias;` import counts too. `Illuminate\Support\Stringable` itself is included if its own declaration names the built-in interface.

Write the result to `ANSWER.txt` in the repository root, one fully qualified class name per line, without a leading backslash, for example `Illuminate\Support\HtmlString`.
