<?php

// The grading sandbox has no node.js, which guzzle's test server (guzzlehttp/test-server) runs on. This bootstrap
// declares a stand-in for GuzzleHttp\Server\Server before the autoloader can load the real one: starting and stopping
// do nothing, and a test that needs the server is skipped at its first call to it. It then runs the project's own
// tests/bootstrap.php. Used by check.sh as `phpunit --bootstrap`.

namespace GuzzleHttp\Server {
    use PHPUnit\Framework\TestCase;

    final class Server
    {
        public static string $url = 'http://127.0.0.1:8126/';
        public static int $port = 8126;

        private static function skip(): never
        {
            TestCase::markTestSkipped('needs the node.js test server, which the grading sandbox does not have');
        }

        public static function flush() { self::skip(); }
        public static function enqueue(...$args): void { self::skip(); }
        public static function enqueueRaw(...$args): void { self::skip(); }
        public static function enqueueRawBytes(...$args): void { self::skip(); }
        public static function enqueueRawByteParts(...$args): void { self::skip(); }
        public static function received(): array { self::skip(); }
        public static function stop(): void {}
        public static function wait(int $maxTries = 5): void { self::skip(); }
        public static function start(): void {}
    }
}

namespace {
    require getcwd() . '/tests/bootstrap.php';
}
