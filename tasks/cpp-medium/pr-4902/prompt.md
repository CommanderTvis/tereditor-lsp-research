# {:N?} miscomputes the width of debug-escaped output

```c++
fmt::print("[{:1?}]\n", std::string(""));  // ["]        missing the closing quote
fmt::print("[{:6?}]\n", 'a');              // ['a'     ] padded to 8, not 6
```

The width is computed from the size before escaping, so debug output pads wrong, and for an
empty string the closing quote gets truncated. `std::format` prints `[""]` and `['a'   ]`.

Happy to put up a PR.
