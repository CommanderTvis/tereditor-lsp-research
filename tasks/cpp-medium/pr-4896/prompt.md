# Inconsistent widths when UTF8 characters are used

Hi,

I find the widths are inconsistent when UTF8 characters are used. I'm not sure whether it's caused by the character display of the terminal or the library implementation.

Example:

```cpp
#include <fmt/format.h>

auto main() -> int {
    fmt::println("|{:^20}|", 12345);
    fmt::println("|{:^20}|", "normal string");
    fmt::println("|{:^20}|", "❌");
    fmt::println("|{:^20}|", "✅");
    fmt::println("|{:^20}|", "Müller");
    fmt::println("|{:^20}|", "我");
    return 0;
}
```
Printouts:

```text
|       12345        |
|   normal string    |
|         ❌          |
|         ✅          |
|       Müller       |
|         我         |
```

[Godbolt link](https://compiler-explorer.com/z/cEWdv8Eob)
