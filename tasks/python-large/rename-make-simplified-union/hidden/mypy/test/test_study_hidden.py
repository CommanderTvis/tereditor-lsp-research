from __future__ import annotations

import io
import os
import tokenize
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def _name_tokens(path: str) -> set[str]:
    with open(path, "rb") as f:
        return {t.string for t in tokenize.tokenize(io.BytesIO(f.read()).readline) if t.type == tokenize.NAME}


# mypy's pytest configuration collects only unittest classes, so the checks are methods of a TestCase.
class StudyHiddenSuite(unittest.TestCase):
    def test_new_name_exists(self) -> None:
        import mypy.typeops
        from mypy.typeops import simplify_union
        from mypy.types import NoneType, UnionType

        assert not hasattr(mypy.typeops, "make_simplified_union")
        assert isinstance(simplify_union([NoneType(), NoneType()]), NoneType)
        assert UnionType is not None

    def test_old_name_not_used_in_mypy(self) -> None:
        offenders = []
        for d, _, files in os.walk(os.path.join(ROOT, "mypy")):
            if os.sep + "typeshed" in d:
                continue
            for f in files:
                if f.endswith(".py") and f != "test_study_hidden.py":
                    p = os.path.join(d, f)
                    if "make_simplified_union" in _name_tokens(p):
                        offenders.append(os.path.relpath(p, ROOT))
        assert offenders == []

    def test_mypyc_method_untouched(self) -> None:
        from mypyc.ir.rtypes import RUnion, int_rprimitive

        assert RUnion.make_simplified_union([int_rprimitive, int_rprimitive]) == int_rprimitive
