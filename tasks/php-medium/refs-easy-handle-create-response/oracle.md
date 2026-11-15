# Oracle: calls of GuzzleHttp\Handler\EasyHandle::createResponse

Derived without a language server: PHPStan 2.1.55 (the version guzzle pins in `vendor-bin/phpstan`) by mutation,
checked against an exhaustive text candidate list.

1. Mutation: rename the declaration (`src/Handler/EasyHandle.php:163`) to `createResponseStudyMutation` and run
   `phpstan analyse --error-format=raw --autoload-file=vendor/autoload.php src tests` with `parameters: level: 9`; every
   `Call to an undefined method GuzzleHttp\Handler\EasyHandle::createResponse()` error is a call: 18 locations
   (`src/Handler/CurlFactory.php:3089`, 2 in `tests/Handler/CurlFactoryTest.php`, 15 in `tests/Handler/EasyHandleTest.php`).
2. Candidates: `rg -n '\bcreateResponse\b' src tests --glob '*.php'`: 28 lines. The 10 not in the oracle: the declaration
   (`src/Handler/EasyHandle.php:163`), a doc comment (`:103`), `$responseFactory->createResponse(...)` on a PSR-17 factory
   (`src/Handler/EasyHandle.php:211`, `src/Handler/StreamHandler.php:462`), StreamHandler's private method (declaration
   `:391`, call `:237`, and `new \ReflectionMethod(StreamHandler::class, 'createResponse')` in
   `tests/Handler/StreamHandlerTest.php:6424`), and PSR-17 implementations in tests (`tests/ClientTest.php:3514`,
   `tests/Handler/EasyHandleTest.php:241`, `tests/Psr17SpyFactory.php:68`).

Judgement calls: none; every call in the oracle has a receiver PHPStan types as `EasyHandle`.
