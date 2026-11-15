# Utils::isHostInNoProxy() fails when a port is set

The first two arguments in the [`explode()` used in `::isHostInNoProxy()`](https://github.com/guzzle/guzzle/blob/55d46a8ba3239be2439fb660b5cc9fba69155113/src/Utils.php#L235) are in the wrong order.  The separator should be the first argument.  This causes `$host` to be set as `:` if there is a port set.
