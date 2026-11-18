import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def test_declared_in_new_module_only():
    import astroid
    from astroid import exceptions
    from astroid import use_inference_default as m

    assert not hasattr(exceptions, "UseInferenceDefault")
    assert "UseInferenceDefault" not in exceptions.__all__
    assert m.UseInferenceDefault.__module__ == "astroid.use_inference_default"
    assert astroid.UseInferenceDefault is m.UseInferenceDefault
    assert issubclass(m.UseInferenceDefault, Exception)


def test_nothing_imports_it_from_exceptions():
    offenders = []
    for base in ("astroid", "tests"):
        for p in (ROOT / base).rglob("*.py"):
            if p.name == "test_study_hidden.py":
                continue
            try:
                tree = ast.parse(p.read_text(encoding="utf-8-sig"))
            except SyntaxError:
                continue
            for node in ast.walk(tree):
                if isinstance(node, ast.ImportFrom) and node.module in ("astroid.exceptions", "exceptions") or (
                    isinstance(node, ast.ImportFrom) and node.level and node.module == "exceptions"
                ):
                    if any(a.name == "UseInferenceDefault" for a in node.names):
                        offenders.append(str(p.relative_to(ROOT)))
    assert offenders == []
