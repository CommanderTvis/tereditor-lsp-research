<?php

declare(strict_types=1);

namespace League\Container\Test;

use League\Container\Container;
use League\Container\ContainerAwareTrait;
use League\Container\ContainerException;
use PHPUnit\Framework\TestCase;
use Psr\Container\ContainerExceptionInterface;

final class StudyHiddenMoveTest extends TestCase
{
    public function testTheExceptionLivesInTheRootNamespaceOnly(): void
    {
        $this->assertTrue(class_exists(ContainerException::class));
        $this->assertFalse(class_exists('League\\Container\\Exception\\' . 'ContainerException'));
        $this->assertTrue(is_subclass_of(ContainerException::class, ContainerExceptionInterface::class));
        $this->assertTrue(is_subclass_of(ContainerException::class, \RuntimeException::class));
    }

    public function testTheTraitThrowsTheMovedException(): void
    {
        $aware = new class {
            use ContainerAwareTrait;
        };
        $this->expectException(ContainerException::class);
        $aware->getContainer();
    }

    public function testTheContainerStillWorks(): void
    {
        $container = new Container();
        $container->add('x', \stdClass::class);
        $this->assertInstanceOf(\stdClass::class, $container->get('x'));
    }
}
