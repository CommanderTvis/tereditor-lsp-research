Rename the module API header `src/redismodule.h` to `src/redis_module_api.h`. Update every `#include` of it and every
other reference to its file name in the code, comments and Makefiles of `src/` (including the example modules in
`src/modules/`), `tests/modules/` and `modules/`. Do not leave a copy or a forwarding header under the old name. The
vendored libraries under `deps/` are not part of this change and must not be modified; Markdown documentation may be
left as it is.
