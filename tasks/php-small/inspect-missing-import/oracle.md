# Oracle: files left with an unresolvable class name after the import clean-up

The defects were seeded (setup.patch); the oracle is PHPStan 2.3.5 (the version in the pinned composer.lock), not a
language server.

Generation: `generate.py` in this directory (`python generate.py <snapshot> src list` lists the candidates;
`--apply <files in seeded order>` applies the edits): for the first 3 files of the seeded order the subject import is deleted; for the last 3 it is
deleted and every use of the short name is written fully qualified.

Check, on the snapshot with setup.patch applied, with `parameters: level: 9` in a scratch neon file:

    vendor/bin/phpstan analyse --error-format=raw -c study-phpstan.neon src tests examples

Errors naming a class that does not exist (`not found`, `unknown class`, `invalid type`, `invalid return type`): 0 before
the patch; after it, 30 in src/ContainerAwareTrait.php (the trait in the context of each class using it), 2 in
src/Definition/Definition.php, 3 in src/Event/OnDefineEvent.php, and none in the three decoys (whose other errors are
the pre-existing ones, shifted by one line).

Judgement calls: none. Every defect is a real resolution failure: `throw new ContainerException` in the root namespace
(the class lives in `League\Container\Exception`), `instanceof ArgumentInterface` and `->getValue()` in
`League\Container\Definition`, and `DefinitionInterface` parameter and return types in `League\Container\Event`.
