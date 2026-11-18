<?php

use Dedoc\Scramble\Infer\Extensions\ExpressionTypeInferenceExtension;
use Dedoc\Scramble\Infer\Extensions\InferExtension;
use Dedoc\Scramble\Support\InferExtensions\TypeTraceInfer;

it('declares the renamed interface in its renamed file', function () {
    expect(interface_exists(ExpressionTypeInferenceExtension::class))->toBeTrue()
        ->and(interface_exists('Dedoc\\Scramble\\Infer\\Extensions\\ExpressionTypeInfer'.'Extension'))->toBeFalse()
        ->and(is_subclass_of(ExpressionTypeInferenceExtension::class, InferExtension::class))->toBeTrue();
});

it('keeps the implementations working', function () {
    expect(is_subclass_of(TypeTraceInfer::class, ExpressionTypeInferenceExtension::class))->toBeTrue();
});
