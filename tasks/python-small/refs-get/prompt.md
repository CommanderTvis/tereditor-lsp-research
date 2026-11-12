I need every place in this repository where the function `get` defined in `toolz/itertoolz.py` is used in code:
imports of it, calls of it, and attribute accesses that resolve to it (such as `toolz.get`).

Do not include its definition, docstrings, comments or string literals (including `__all__` entries), or places
where the name `get` is bound to something else (a local variable, a lambda, a method, or the curried `get` from
`toolz.curried`).

Write the result to `ANSWER.txt` in the repository root, one location per line as `relative/path.py:LINE`
(1-based line number), for example `toolz/foo.py:12`.
