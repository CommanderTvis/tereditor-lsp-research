<?php

declare(strict_types=1);

namespace GuzzleHttp\Tests;

use GuzzleHttp\Exception\RequestException;
use GuzzleHttp\Handler\CurlFactory;
use GuzzleHttp\Handler\CurlFactoryInterface;
use GuzzleHttp\Handler\EasyHandle;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Psr7\Request;
use PHPUnit\Framework\TestCase;

final class StudyHiddenRenameTest extends TestCase
{
    public function testTheFactoryMethodIsRenamed(): void
    {
        self::assertTrue(\method_exists(CurlFactoryInterface::class, 'createEasyHandle'));
        self::assertFalse(\method_exists(CurlFactoryInterface::class, 'create'));
        self::assertTrue(\method_exists(CurlFactory::class, 'createEasyHandle'));
        self::assertFalse(\method_exists(CurlFactory::class, 'create'));
    }

    public function testTheOtherCreateMethodsKeepTheirNames(): void
    {
        self::assertTrue(\method_exists(RequestException::class, 'create'));
        self::assertTrue(\method_exists(HandlerStack::class, 'create'));
    }

    public function testTheRenamedMethodCreatesAHandle(): void
    {
        $factory = new CurlFactory(1);
        $easy = $factory->createEasyHandle(new Request('GET', 'http://127.0.0.1:1/'), []);
        self::assertInstanceOf(EasyHandle::class, $easy);
        $factory->release($easy);
    }
}
