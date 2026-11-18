# Oracle: files left with an unresolvable class name after the import clean-up

The defects were seeded (setup.patch); the oracle is PHPStan (the version in projects/php-xlarge/locks), not a language server.

Generation: `generate.py` in this directory (`python3 generate.py <snapshot> src/Core/Checkout/Cart list` lists the candidates; `--apply <files in seeded order>`
applies the edits). Seeded order: src/Core/Checkout/Cart/Rule/LineItemDimensionHeightRule.php, src/Core/Checkout/Cart/Rule/LineItemDimensionVolumeRule.php, src/Core/Checkout/Cart/Rule/LineItemRule.php, src/Core/Checkout/Cart/Rule/LineItemInCategoryRule.php, src/Core/Checkout/Cart/Delivery/Struct/DeliveryPosition.php, src/Core/Checkout/Cart/Facade/Traits/ItemsIteratorTrait.php; the first 3 get the defect, the last 3 the decoy.

Check, on the snapshot with setup.patch applied, with `parameters: level: 9`:

    vendor/bin/phpstan analyse --no-progress --error-format=raw -c study-phpstan.neon <the six files>

Errors naming a class that does not exist (`not found`, `unknown class`, `invalid type`): none in the three decoys; in LineItemDimensionHeightRule.php and
LineItemDimensionVolumeRule.php (`DeliveryInformation`) and LineItemRule.php (`LineItem`) after the patch.

Judgement calls: none. Every defect is a real resolution failure (the name resolves to a non-existent class in the file's own namespace).
