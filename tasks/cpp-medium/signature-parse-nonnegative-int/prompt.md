Change the parameter order of `fmt::detail::parse_nonnegative_int` from `(begin, end, error_value)` to
`(end, begin, error_value)`: the end of the range comes first and is taken by value, the begin pointer (still taken by
reference and advanced past the parsed digits) comes second, `error_value` stays last. Its behaviour does not change.
Update every call site in the headers, sources and tests accordingly; do not keep an overload with the old order.
