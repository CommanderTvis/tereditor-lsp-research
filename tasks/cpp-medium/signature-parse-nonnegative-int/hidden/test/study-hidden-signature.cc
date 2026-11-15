// Held-out check of the signature change: parse_nonnegative_int(end, begin, error_value). The end pointer is passed
// as an rvalue, which does not compile with the old (begin by reference first) order. Then every caller's behaviour.
#include "fmt/format.h"
#include "fmt/printf.h"

#include <cstdio>
#include <string>

static int check(const std::string& got, const char* want) {
  if (got == want) return 0;
  std::printf("got '%s', want '%s'\n", got.c_str(), want);
  return 1;
}

int main() {
  int fails = 0;
  const char s[] = "42x";
  const char* begin = s;
  fails += fmt::detail::parse_nonnegative_int(s + 3, begin, -1) != 42 || begin != s + 2;
  const char big[] = "99999999999";
  const char* b2 = big;
  fails += fmt::detail::parse_nonnegative_int(big + 11, b2, -7) != -7;
  const wchar_t ws[] = L"7";
  const wchar_t* wb = ws;
  fails += fmt::detail::parse_nonnegative_int(ws + 1, wb, -1) != 7;

  fails += check(fmt::format("{:>5}", 1), "    1");
  fails += check(fmt::format("{1}{0}", 'a', 'b'), "ba");
  fails += check(fmt::format("{:.{}f}", 3.14159, 2), "3.14");
  fails += check(fmt::format("{0:{1}}", 7, 3), "  7");
  fails += check(fmt::sprintf("%5d", 3), "    3");
  fails += check(fmt::sprintf("%.3s", "abcdef"), "abc");
  fails += check(fmt::sprintf("%*d", 4, 7), "   7");
  fails += check(fmt::sprintf("%1$d %1$d", 5), "5 5");
  fails += check(fmt::sprintf("%2$*1$d", 3, 9), "  9");
  fails += check(fmt::sprintf("%2$.*1$f", 1, 2.25), "2.2");
  std::printf("hidden signature check: %d failures\n", fails);
  return fails != 0;
}
