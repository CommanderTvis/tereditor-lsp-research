The compiled part of the library exports a set of functions: those declared with `FMT_API` in `include/fmt/*.h`
(including the member functions of classes declared `FMT_API`). I need to know which of these exported functions
outside the internal namespace `fmt::detail` can end up calling `fmt::detail::fwrite_all`, directly or through any
chain of other functions, in a Linux build (code under `_WIN32` is not compiled).

Write the result to `ANSWER.txt` in the repository root, one fully qualified function name per line, without
parameters or return type, for example `fmt::file::read` or `fmt::format_system_error`. Overloads with the same name
count once. Do not list functions in `fmt::detail`, functions that are not exported, or `fwrite_all` itself.
