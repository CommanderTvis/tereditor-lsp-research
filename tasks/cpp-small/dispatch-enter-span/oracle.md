# Oracle: the function that `ctx->parser.enter_span` runs in md2html

Not derived from a language server. `MD_PARSER` in `src/md4c.h` declares its members in the order `abi_version`, `flags`,
`enter_block`, `leave_block`, `enter_span`, `leave_span`, `text`, `debug_log`, `syntax`. `md2html` converts a document
only through `md_html()` (`md2html/md2html.c`), which builds its parser in `src/md4c-html.c` with a positional initializer:
`0, parser_flags, enter_block_callback, leave_block_callback, enter_span_callback, ...`, so the fifth member is
`enter_span_callback`, defined (the only definition, `static`) with its name on line 502 of `src/md4c-html.c`.
`derive-oracle.sh` confirms it at run time: it builds `md2html` with a marker printed from each callback of
`md4c-html.c` and converts `*x*`: the emphasis span produces exactly one `enter_span` marker (and one `leave_span`), so the span callbacks that `md_parse` calls are the ones installed in `md_html`.

No judgement calls. `md_html` is the only place `md2html` assigns the callbacks; the fuzzer `test/fuzzers/fuzz-mdhtml.c`
uses the same function.
