// Held-out check of the move: iterator_buffer is named fmt::iterator_buffer, and fmt::detail no longer declares it
// (the variable below would clash with any declaration or alias of that name left in fmt::detail).
#include "fmt/compile.h"
#include "fmt/format.h"
#include "fmt/xchar.h"

#include <cstdio>
#include <cstring>
#include <iterator>
#include <list>
#include <string>
#include <vector>

FMT_BEGIN_NAMESPACE
namespace detail {
int iterator_buffer = 0;
}  // namespace detail
FMT_END_NAMESPACE

int main() {
  int fails = 0;
  std::list<char> l;
  {
    fmt::iterator_buffer<std::back_insert_iterator<std::list<char>>, char> b(std::back_inserter(l));
    b.push_back('a');
    b.push_back('b');
    b.out();
  }
  fails += std::string(l.begin(), l.end()) != "ab";

  std::string s;
  {
    fmt::iterator_buffer<std::back_insert_iterator<std::string>, char> b(std::back_inserter(s));
    b.push_back('x');
  }
  fails += s != "x";

  char out[8] = {};
  {
    fmt::iterator_buffer<char*, char, fmt::detail::fixed_buffer_traits> b(out, 3);
    const char digits[] = "12345";
    b.append(digits, digits + 5);
    fails += b.count() != 5;
    b.out();
  }
  fails += std::strncmp(out, "123", 3) != 0;

  char out2[8] = {};
  auto r = fmt::format_to_n(out2, 3, "{}", 12345);
  fails += r.size != 5 || std::strncmp(out2, "123", 3) != 0;
  char out3[8] = {};
  auto r3 = fmt::format_to_n(out3, 2, FMT_COMPILE("{}"), 678);
  fails += r3.size != 3 || std::strncmp(out3, "67", 2) != 0;
  wchar_t wout[8] = {};
  auto rw = fmt::format_to_n(wout, 2, L"{}", 91);
  fails += rw.size != 2 || wout[0] != L'9';
  std::vector<char> v;
  fmt::format_to(std::back_inserter(v), "{}", 42);
  fails += std::string(v.begin(), v.end()) != "42";

  std::printf("hidden move check: %d failures\n", fails);
  return fails != 0;
}
