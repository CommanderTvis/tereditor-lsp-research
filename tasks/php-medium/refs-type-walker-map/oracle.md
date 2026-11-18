# Oracle: calls of Dedoc\Scramble\Support\Type\TypeWalker::map in src/

Derived without a language server: PHPStan (the version in projects/php-medium/locks) by mutation, checked against a text candidate list.

1. Mutation: rename the declaration in `src/Support/Type/TypeWalker.php` to `mapStudyMutation` and run
   `phpstan analyse --error-format=raw -c study-phpstan.neon` (`parameters: level: 9, paths: src`); every
   `Call to an undefined method Dedoc\Scramble\Support\Type\TypeWalker::map()` error is a call: 21 locations.
2. Candidates: `rg -n -- '(->|::)map\(' src` lists every call of any `map()`; the lines not in the oracle are calls of other types'
   `map()` (ArgumentTypeBag and its implementations, collections, Generator types) with receivers PHPStan types as other classes.

Scope: `src/` only. The Pest tests call `map()` on untyped receivers, so PHPStan cannot decide them; the prompt excludes `tests/`.

Judgement calls: none for the listed calls.
