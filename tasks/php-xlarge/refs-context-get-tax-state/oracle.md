# Oracle: calls of Shopware\Core\Framework\Context::getTaxState in src/

Derived without a language server: PHPStan (the version in projects/php-xlarge/locks) by mutation, checked against a text candidate list.

1. Mutation: rename the declaration (`src/Core/Framework/Context.php:253`) to `getTaxStateStudyMutation` and run
   `phpstan analyse --error-format=raw -c study-phpstan.neon <files>` (`parameters: level: 9`) on the files that contain `->getTaxState(` or
   `::getTaxState(` plus Context.php; every `Call to an undefined method Shopware\Core\Framework\Context::getTaxState()` error is a call: 14 locations.
2. Candidates: `rg -n --glob '*.php' '(->|::)getTaxState\(' src`: 40 lines. The others are calls on `SalesChannelContext`, `BaseSalesChannelContext`
   (own method of the same name, outside Context's hierarchy) and `TaxDetector::getTaxState($context)`, whose receivers PHPStan types as those classes.

Scope: `src/` only (the unit tests use mocks and untyped receivers).

Judgement calls: none for the listed calls.
