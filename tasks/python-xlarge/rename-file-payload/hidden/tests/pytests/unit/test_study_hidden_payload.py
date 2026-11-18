import ast
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


def test_module_moved():
    assert not os.path.exists(os.path.join(ROOT, "salt", "payload.py"))
    assert os.path.exists(os.path.join(ROOT, "salt", "wire_payload.py"))


def test_new_module_importable():
    import salt.wire_payload as m

    assert hasattr(m, "Serial") or hasattr(m, "loads")


def test_old_module_not_imported():
    offenders = []
    for top in ("salt", "tests", "tools", "scripts"):
        for d, _, files in os.walk(os.path.join(ROOT, top)):
            for f in files:
                if not f.endswith(".py") or f == "test_study_hidden_payload.py":
                    continue
                p = os.path.join(d, f)
                try:
                    with open(p, "rb") as fh:
                        tree = ast.parse(fh.read())
                except (SyntaxError, ValueError):
                    continue
                for node in ast.walk(tree):
                    if isinstance(node, ast.ImportFrom):
                        names = [a.name for a in node.names]
                        if node.module == "salt.payload" or (node.module == "salt" and "payload" in names):
                            offenders.append(os.path.relpath(p, ROOT))
                    elif isinstance(node, ast.Import):
                        if any(a.name == "salt.payload" for a in node.names):
                            offenders.append(os.path.relpath(p, ROOT))
    assert offenders == []
