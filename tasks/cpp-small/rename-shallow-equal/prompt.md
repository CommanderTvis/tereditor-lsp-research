Rename the virtual member function `XMLNode::ShallowEqual` to `IsShallowEqual`, together with every override of it, in
the library, its tests and `contrib/`. Do not keep the old name as an alias, and leave no mention of the old name in
any `.h` or `.cpp` file (comments and test labels included). The generated HTML documentation in `docs/` does not need
to be updated.
