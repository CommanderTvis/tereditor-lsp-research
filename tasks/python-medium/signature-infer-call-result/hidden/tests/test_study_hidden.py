import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def _defs():
    for p in (ROOT / "astroid").rglob("*.py"):
        tree = ast.parse(p.read_text(encoding="utf-8-sig"))
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef):
                for b in node.body:
                    if isinstance(b, ast.FunctionDef) and b.name == "infer_call_result":
                        yield p, node.name, b


def test_every_implementation_takes_strict():
    seen = 0
    for p, cls, fn in _defs():
        seen += 1
        kw = {a.arg: d for a, d in zip(fn.args.kwonlyargs, fn.args.kw_defaults)}
        assert "strict" in kw, f"{p.relative_to(ROOT)}:{fn.lineno} {cls}"
        assert isinstance(kw["strict"], ast.Constant) and kw["strict"].value is False
    assert seen >= 15


def test_delegating_calls_forward_it():
    for p, cls, fn in _defs():
        for node in ast.walk(fn):
            if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute) and node.func.attr == "infer_call_result":
                assert any(k.arg == "strict" for k in node.keywords), f"{p.relative_to(ROOT)}:{node.lineno}"


def test_callable_with_strict():
    import astroid

    func = astroid.extract_node("def f():\n    return 1\nf  #@")
    inferred = next(func.infer())
    assert next(inferred.infer_call_result(None, strict=True)).value == 1
