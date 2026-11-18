# [Bug]: Closure routes log deprecations, and scramble:cache crashes after route:cache

### What happened?

`php artisan scramble:analyze` (same with `scramble:export`) exits 0, but `storage/logs/deprecations.log` gets three warnings while documenting a closure route:

- `str_replace(): Passing null to parameter #3 ($subject)` from `class_basename()` in `RequestEssentialsExtension.php:46`
- `mb_strtoupper(): Passing null to parameter #1 ($string)` from `Str::upper()` in `RequestEssentialsExtension.php:206`
- `str_replace(): Passing null to parameter #3 ($subject)` from `Str::camel()` in `RequestEssentialsExtension.php:210`

I expected those commands to generate the spec for that route without deprecation warnings.

Then, after `php artisan route:cache`, `php artisan scramble:cache` does not log anything. It crashes:

```
ArgumentCountError

ReflectionMethod::__construct() expects at most 2 arguments, 3 given

at vendor/dedoc/scramble/src/Support/RouteProviders/RouteProvider.php:66
    $reflection = new ReflectionMethod(...explode('@', $route->getAction('uses')));
```

I expected `scramble:cache` to finish and write the OpenAPI cache.

### How to reproduce the bug

https://github.com/hosni-labs/dedoc-scramble-1214-1215-1216

The only app route is a closure, `GET /api/version`, in `routes/api.php`. Scramble is the default install, no extra config.

`.env.example` has `LOG_DEPRECATIONS_CHANNEL=null`, which drops deprecations. In `.env`:

```
LOG_DEPRECATIONS_CHANNEL=deprecations
```

```
composer install
cp .env.example .env
php artisan key:generate

php artisan scramble:analyze
tail storage/logs/deprecations.log

php artisan route:cache
php artisan scramble:cache
```

The first command exits 0 and appends the three warnings. The last command exits with the `ArgumentCountError` above. That error is printed by Artisan. It is not written to `deprecations.log`.

### Package Version

0.13.45

### PHP Version

8.4.25

### Laravel Version

13.33.0

### Which operating systems does with happen with?

Linux

### Notes

Follow-up to #1214, #1215, and #1216.

`RouteInfo::isClassBased()` is `is_string($route->getAction('uses'))` (https://github.com/dedoc/scramble/blob/v0.13.45/src/Support/RouteInfo.php#L53-L69). A closure is not a string, so `className()` and `methodName()` are null. Those nulls are passed to `class_basename()`, `Str::upper()`, and `Str::camel()` (https://github.com/dedoc/scramble/blob/v0.13.45/src/Support/OperationExtensions/RequestEssentialsExtension.php#L46 and https://github.com/dedoc/scramble/blob/v0.13.45/src/Support/OperationExtensions/RequestEssentialsExtension.php#L202-L211).

After `route:cache`, Laravel stores the closure as a serialized `UnsignedSerializableClosure` string. `is_string()` is then true, and line 66 treats that string as `Controller@method` (https://github.com/dedoc/scramble/blob/v0.13.45/src/Support/RouteProviders/RouteProvider.php#L65-L67). This closure's serialized body contains two `@` from the `@var` lines, so `explode` returns 3 parts. `ArgumentCountError` is not a `ReflectionException`, so the catch on the next line does not handle it.

The same `new ReflectionMethod(...explode('@', ...))` at line 43 catches `Throwable`, so only line 66 takes the command down (https://github.com/dedoc/scramble/blob/v0.13.45/src/Support/RouteProviders/RouteProvider.php#L42-L48).
