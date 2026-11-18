I need every class in this repository that inherits, directly or indirectly, from `FunctionDef` (defined in
`astroid/nodes/scoped_nodes/scoped_nodes.py`), wherever it is defined in a `.py` file: the library, the brain plugins, the
tests or elsewhere, including classes defined inside functions. The base may be written as `FunctionDef`,
`nodes.FunctionDef` or `scoped_nodes.FunctionDef`.

Do not include `FunctionDef` itself, and do not include classes that inherit only from `Lambda` or from the other scoped
node classes without going through `FunctionDef`.

Write the result to `ANSWER.txt` in the repository root, one class per line as `relative/path.py:LINE`, where LINE is
the 1-based line of the class's `class` statement, for example `astroid/foo.py:12`.
