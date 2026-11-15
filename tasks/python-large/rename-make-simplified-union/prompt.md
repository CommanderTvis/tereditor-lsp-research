Rename the function `make_simplified_union` defined in `mypy/typeops.py` to `simplify_union`, everywhere it is
imported or called in the code base, including plugins and tests. Do not keep the old name as an alias. The unrelated
static method `RUnion.make_simplified_union` in `mypyc/ir/rtypes.py` and its callers must keep their name. Updating
comments and documentation is optional.
