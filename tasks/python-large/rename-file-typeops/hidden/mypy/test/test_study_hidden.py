from __future__ import annotations

import ast
import os
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


# mypy's pytest configuration collects only unittest classes, so the checks are methods of a TestCase.
class StudyHiddenSuite(unittest.TestCase):
    def test_module_moved(self) -> None:
        assert not os.path.exists(os.path.join(ROOT, "mypy", "typeops.py"))
        assert os.path.exists(os.path.join(ROOT, "mypy", "type_operations.py"))

    def test_new_module_importable(self) -> None:
        import mypy.type_operations as m

        assert hasattr(m, "make_simplified_union")

    def test_old_module_not_imported(self) -> None:
        offenders = []
        for d, _, files in os.walk(os.path.join(ROOT, "mypy")):
            if os.sep + "typeshed" in d:
                continue
            for f in files:
                if not f.endswith(".py") or f == "test_study_hidden.py":
                    continue
                p = os.path.join(d, f)
                with open(p, "rb") as fh:
                    tree = ast.parse(fh.read())
                for node in ast.walk(tree):
                    if isinstance(node, ast.ImportFrom):
                        names = [a.name for a in node.names]
                        if node.module == "mypy.typeops" or (node.module == "mypy" and "typeops" in names):
                            offenders.append(os.path.relpath(p, ROOT))
                    elif isinstance(node, ast.Import):
                        if any(a.name == "mypy.typeops" for a in node.names):
                            offenders.append(os.path.relpath(p, ROOT))
        assert offenders == []
