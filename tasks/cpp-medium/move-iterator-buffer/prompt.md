Move the class template `iterator_buffer`, together with all of its partial specializations, out of the internal
namespace `fmt::detail` into the public namespace `fmt`, so that users can name it as `fmt::iterator_buffer`. It stays
in `include/fmt/base.h`. Update every reference to it in the headers, sources and tests. Do not leave an alias, a
using-declaration or a forwarding declaration of it in `fmt::detail`.
