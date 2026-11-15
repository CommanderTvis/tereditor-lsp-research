<?php

declare(strict_types=1);

namespace GuzzleHttp\Tests;

use GuzzleHttp\Handler\CurlFactoryInterface;
use GuzzleHttp\Handler\CurlHandleFactory;
use GuzzleHttp\Handler\CurlHandler;
use GuzzleHttp\Handler\CurlMultiHandler;
use PHPUnit\Framework\TestCase;

final class StudyHiddenRenameFileTest extends TestCase
{
    public function testTheClassIsRenamed(): void
    {
        self::assertTrue(\class_exists(CurlHandleFactory::class));
        self::assertFalse(\class_exists('GuzzleHttp\\Handler\\Curl' . 'Factory'));
        self::assertTrue(\is_subclass_of(CurlHandleFactory::class, CurlFactoryInterface::class));
        self::assertTrue(\interface_exists(CurlFactoryInterface::class));
    }

    public function testTheHandlersBuildTheRenamedFactory(): void
    {
        foreach ([new CurlHandler(), new CurlMultiHandler()] as $handler) {
            $factory = (fn () => $this->factory)->call($handler);
            self::assertInstanceOf(CurlHandleFactory::class, $factory);
        }
    }
}
