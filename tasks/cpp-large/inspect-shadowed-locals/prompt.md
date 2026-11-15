Code review request. We want to find functions where a variable declared in an inner block has the same name as a
local variable or a parameter of an enclosing scope of the same function (the inner declaration shadows the outer
one). Which of the following ten files contain at least one such declaration?

- `src/commands.c`
- `src/debug.c`
- `src/lolwut6.c`
- `src/lolwut8.c`
- `src/module.c`
- `src/redis-check-aof.c`
- `src/sentinel.c`
- `src/socket.c`
- `src/sort.c`
- `src/t_hash.c`

Only declarations written in the file itself count: not ones that appear only through the expansion of a macro, and
not ones in headers the file includes. Code in every `#if`/`#ifdef` branch counts. Shadowing of global variables or of
functions does not count.

Write the result to `ANSWER.txt` in the repository root, one path per line for each file that contains at least one
such declaration, exactly as listed above (for example `src/foo.c`).
