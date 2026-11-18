# Oracle: classes naming \Stringable in their implements clause (laravel/framework f5c01f6, src/)

Derived without a language server: PHP's own tokenizer (`token_get_all`, php 8.4) over every .php file under src/. For each
`class` declaration (not `::class`, not `new class`) the names in its `implements` clause are resolved against the
file's namespace and top-level `use` imports (aliases included); a class is kept if one resolves to `Stringable` in the
global namespace. Cross-check: `rg -U --pcre2 'class\s+\w+[^{;]*implements[^{]*\bStringable\b' src` matches 48 files, the 48
classes of the oracle other than `Illuminate\Support\Stringable`, which imports the built-in interface as
`BaseStringable` (the scan resolves the alias, the text search cannot). 49 classes in total.

Judgement calls: inherited and implicit (`__toString()` only) implementers are excluded by the prompt; interfaces
extending Stringable are excluded.
