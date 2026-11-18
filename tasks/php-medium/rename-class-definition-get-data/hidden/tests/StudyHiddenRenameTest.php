<?php

use Dedoc\Scramble\Infer\Contracts\ClassDefinition as ClassDefinitionContract;
use Dedoc\Scramble\Infer\Definition\ClassDefinition;
use Dedoc\Scramble\Infer\Definition\LazyShallowClassDefinition;

it('renames getData on the contract and its implementations', function () {
    foreach ([ClassDefinitionContract::class, ClassDefinition::class, LazyShallowClassDefinition::class] as $class) {
        expect(method_exists($class, 'getDefinitionData'))->toBeTrue("$class::getDefinitionData")
            ->and(method_exists($class, 'getData'))->toBeFalse("$class::getData");
    }
});

it('still returns the class data', function () {
    $definition = new ClassDefinition(name: 'Foo');

    expect($definition->getDefinitionData())->toBe($definition);
});
