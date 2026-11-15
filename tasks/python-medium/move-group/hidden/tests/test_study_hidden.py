import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _py_files():
    for top in ("rich", "tests", "examples", "benchmarks", "tools"):
        d = ROOT / top
        if d.is_dir():
            yield from sorted(d.rglob("*.py"))


def test_group_lives_in_rich_group():
    from rich.group import Group

    assert Group.__module__ == "rich.group"
    tree = ast.parse((ROOT / "rich" / "group.py").read_text(encoding="utf-8"))
    assert any(isinstance(n, ast.ClassDef) and n.name == "Group" for n in tree.body)


def test_group_not_declared_in_console():
    tree = ast.parse((ROOT / "rich" / "console.py").read_text(encoding="utf-8"))
    assert not any(isinstance(n, ast.ClassDef) and n.name == "Group" for n in ast.walk(tree))


def test_nothing_imports_group_from_console():
    offenders = []
    for path in _py_files():
        if path.name == "test_study_hidden.py":
            continue
        tree = ast.parse(path.read_text(encoding="utf-8"))
        in_rich = path.parent == ROOT / "rich"
        for node in ast.walk(tree):
            if not isinstance(node, ast.ImportFrom):
                continue
            from_console = node.module == "rich.console" or (
                in_rich and node.level == 1 and node.module == "console"
            )
            if from_console and any(a.name == "Group" for a in node.names):
                offenders.append(f"{path.relative_to(ROOT)}:{node.lineno}")
    assert offenders == []


def test_group_still_renders():
    from rich.console import Console, group
    from rich.group import Group
    from rich.text import Text

    @group()
    def two():
        yield Text("foo")
        yield Text("bar")

    g = two()
    assert isinstance(g, Group)
    console = Console(width=20, file=None, record=True, color_system=None)
    with console.capture() as capture:
        console.print(Group(Text("a"), Text("b")))
        console.print(g)
    assert capture.get() == "a\nb\nfoo\nbar\n"
