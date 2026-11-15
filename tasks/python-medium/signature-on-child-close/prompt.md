`MarkdownElement.on_child_close` in `rich/markdown.py` receives a `context` argument that no implementation uses.
Remove that parameter: the method should become `on_child_close(self, child)` on `MarkdownElement` and on every class
that overrides it, and every call of it must be updated accordingly. Keep the docstring in line with the new
signature. Rendering of Markdown must not change.
