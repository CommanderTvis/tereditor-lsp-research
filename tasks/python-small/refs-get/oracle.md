# Oracle: references of toolz.itertoolz.get

Derived without a language server: an exhaustive candidate list, then a manual decision per line.

    rg -n '\bget\b' --type py     # 57 lines at the pinned commit

Every candidate was classified. Kept: imports, calls and attribute accesses bound to `toolz.itertoolz.get`.
Dropped, with the reason:

- `toolz/itertoolz.py:414` the definition; `:13` the `__all__` string; `:419-441`, `:775`, `:792` docstrings.
- `toolz/itertoolz.py:796-797` local `get = getter(ind)` inside `pluck`.
- `toolz/dicttoolz.py:331` docstring "See Also".
- `toolz/curried/__init__.py:9-20` docstring; `:68` is kept (`toolz.curry(toolz.get)` reads `toolz.get`).
- `bench/test_curry.py:1,8` and `bench/test_join.py:18` bind `get` from `toolz.curried` (a different object).
- `toolz/tests/test_itertoolz.py:440-446` local lambdas named `get`.
- `toolz/tests/test_dicttoolz.py:219` a comment.
- `.get(` method calls on dicts (all other candidates).

Judgement calls: `toolz/curried/__init__.py:68` (kept: `toolz.get` is an attribute access resolving to the function).
