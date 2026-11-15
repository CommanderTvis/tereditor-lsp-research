Rename the method `create()` of `GuzzleHttp\Handler\CurlFactoryInterface` to `createEasyHandle()`: in the interface, in
every class that implements it (including any implementations in the tests), and at every place that calls it or
refers to it by name, in the library and the tests. Do not keep the old name as an alias.

Other methods called `create()` in the package (for example `RequestException::create()` and `HandlerStack::create()`)
are unrelated and keep their names. Updating documentation files is optional.
