I need every class in this repository that inherits, directly or indirectly, from `RegexHighlighter` (defined in
`rich/highlighter.py`), wherever it is defined in a `.py` file: the library, the tests, the examples or elsewhere.

Do not include `RegexHighlighter` itself, and do not include classes that inherit only from `Highlighter` without
going through `RegexHighlighter`.

Write the result to `ANSWER.txt` in the repository root, one class per line as `relative/path.py:LINE`, where LINE is
the 1-based line of the class's `class` statement, for example `rich/foo.py:12`.
