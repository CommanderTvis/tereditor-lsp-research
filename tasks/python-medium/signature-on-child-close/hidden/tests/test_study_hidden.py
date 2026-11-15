import inspect

import rich.markdown as md
from rich.console import Console
from rich.markdown import Markdown, MarkdownElement


def _overriders():
    seen = []
    for obj in vars(md).values():
        if inspect.isclass(obj) and issubclass(obj, MarkdownElement) and "on_child_close" in vars(obj):
            seen.append(obj)
    return seen


def test_signature_everywhere():
    classes = _overriders()
    assert MarkdownElement in classes and len(classes) >= 8
    for cls in classes:
        params = list(inspect.signature(vars(cls)["on_child_close"]).parameters)
        assert params == ["self", "child"], (cls.__name__, params)


def test_base_returns_true():
    assert MarkdownElement().on_child_close(MarkdownElement()) is True


DOC = """\
# Title

Some *text* and a list:

1. one
2. two

- a
- b

> quoted

| h1 | h2 |
|----|----|
| x  | y  |
"""


def test_render_still_works():
    console = Console(width=40, color_system=None, record=True)
    with console.capture() as capture:
        console.print(Markdown(DOC))
    out = capture.get()
    for word in ("Title", "one", "two", "quoted", "h1", "x"):
        assert word in out
