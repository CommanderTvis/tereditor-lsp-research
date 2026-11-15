<?php

declare(strict_types=1);

namespace League\Container\Test;

use League\Container\Container;
use League\Container\DefinitionContainerInterface;
use PHPUnit\Framework\TestCase;
use ReflectionMethod;
use stdClass;

final class StudyHiddenSignatureTest extends TestCase
{
    public function testTheParametersAreInTheNewOrder(): void
    {
        foreach ([DefinitionContainerInterface::class, Container::class] as $type) {
            $names = array_map(
                static fn ($p) => $p->getName(),
                (new ReflectionMethod($type, 'add'))->getParameters()
            );
            $this->assertSame(['id', 'concrete', 'shared', 'overwrite'], $names, $type);
        }
    }

    public function testTheThirdArgumentSharesTheService(): void
    {
        $container = new Container();
        $container->add('shared', stdClass::class, true);
        $container->add('fresh', stdClass::class, false);
        $this->assertSame($container->get('shared'), $container->get('shared'));
        $this->assertNotSame($container->get('fresh'), $container->get('fresh'));
        $this->assertTrue($container->extend('shared')->isShared());
    }

    public function testTheFourthArgumentOverwrites(): void
    {
        $one = new stdClass();
        $two = new stdClass();
        $container = new Container();
        $container->add('foo', $one);
        $container->add('foo', $two, false, true);
        $this->assertSame($two, $container->get('foo'));
        $container->add('bar', $one);
        $container->add('bar', $two, overwrite: true);
        $this->assertSame($two, $container->get('bar'));
    }

    public function testSharedAndOverwriteTogether(): void
    {
        $container = new Container();
        $container->add('baz', stdClass::class);
        $container->add('baz', \ArrayObject::class, true, true);
        $this->assertInstanceOf(\ArrayObject::class, $container->get('baz'));
        $this->assertSame($container->get('baz'), $container->get('baz'));
    }
}
