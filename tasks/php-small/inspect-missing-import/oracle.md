# Oracle: files left with an unresolvable class name after the import clean-up

The defects were seeded (setup.patch); the oracle is PHPStan 2.2.13 (the version in projects/php-small/locks), not a language server.

Generation: `generate.py` in this directory (`python3 generate.py <snapshot> src list` lists the candidates; `--apply <files in seeded order>`
applies the edits): for the first 3 files of the seeded order the subject import is deleted; for the last 3 it is deleted and every use of the short
name is written fully qualified. Seeded order: src/Utilities/Helper.php, src/Facades/DataTables.php, src/EloquentDataTable.php, src/DataTables.php, src/Processors/RowProcessor.php, src/QueryDataTable.php.

Check, on the snapshot with setup.patch applied, with `parameters: level: 9` in a scratch neon file:

    vendor/bin/phpstan analyse --error-format=raw -c study-phpstan.neon src tests

Errors naming a class that does not exist (`not found`, `unknown class`, `invalid type`): none before the patch for the three files; after it, in
src/Utilities/Helper.php (`Arrayable`), src/EloquentDataTable.php (`Model`) and src/Facades/DataTables.php (`Facade`), and none in the three decoys
(DataTables.php, Processors/RowProcessor.php, QueryDataTable.php). The other errors reported ("argument of an invalid type mixed supplied for foreach",
generics) are pre-existing and identical before and after.

Judgement calls: none. Every defect is a real resolution failure (the name resolves to a non-existent class in the file's own namespace).
