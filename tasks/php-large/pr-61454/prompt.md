# SelfBuilding factory is bypassed after a previous resolution throws an exception

### Laravel Version

13.x-dev (`cdbd17f7e3257e8ae4207d3c3bef6058452d5f72`)

### PHP Version

8.5.10

### Database Driver & Version

N/A

### Description

When a `SelfBuilding::newInstance()` factory throws an exception, the container retains the class in its `buildStack`. A subsequent resolution of the same class through the same container skips the factory and constructs the object directly.

This can bypass validation or initialization performed by the factory. The existing `AolInstantMessengerConfig` integration-test fixture demonstrates the problem: its factory rejects an away-message duration below 60, but after the first `ValidationException`, a second resolution returns an object with duration 5.

Expected behavior: each independent resolution should invoke the factory and reject the invalid configuration. The factory's intentional recursive `app()->build(static::class)` call should continue to work while the factory is active.

The stack entry is added by `Container::buildSelfBuildingInstance()`, but its `array_pop()` only runs when the factory returns normally. The nested `Container::call()` does not own this entry because the class is already on the stack.

### Steps To Reproduce

1. Use the framework checkout at the commit above with its development dependencies installed.
2. Open [tests/Integration/Container/BuildableIntegrationTest.php](https://github.com/laravel/framework/blob/cdbd17f7e3257e8ae4207d3c3bef6058452d5f72/tests/Integration/Container/BuildableIntegrationTest.php).
3. In `test_build_method_can_resolve_itself_via_container()`, preserve the initial valid configuration and assertions. Replace the final single `try/catch` with the following loop, keeping the existing `config(['aim.away_message.duration' => 5]);` immediately before it:

```php
for ($attempt = 1; $attempt <= 2; $attempt++) {
    try {
        $this->app->make(AolInstantMessengerConfig::class);

        $this->fail("Expected a validation exception on attempt {$attempt}.");
    } catch (ValidationException $exception) {
        $this->assertArrayHasKey('away_message.duration', $exception->errors());
        $this->assertStringContainsString('60', $exception->errors()['away_message.duration'][0]);
    }
}
```

4. Run:

```bash
vendor/bin/phpunit tests/Integration/Container/BuildableIntegrationTest.php --filter test_build_method_can_resolve_itself_via_container
```

The two attempts use the same application/container, without flushing or recreating it.

**Actual result:** the first attempt throws the expected `ValidationException`; the second returns normally and the test fails with:

```text
Expected a validation exception on attempt 2.
```

**Expected result:** both attempts throw `ValidationException`.

I reproduced this failure before changing production code. Locally, putting the factory call inside `try` and moving its stack cleanup into `finally` makes the regression pass. The expanded test also verifies recovery on the same container after setting duration to 60 and body to `back online`, using the fixture's existing recursive build path.

