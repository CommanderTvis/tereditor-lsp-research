import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def test_module_moved():
    assert not (ROOT / 'pydantic_extra_types' / 'phone_numbers.py').exists()
    assert (ROOT / 'pydantic_extra_types' / 'phone_number.py').exists()


def test_new_module_importable():
    from pydantic_extra_types.phone_number import PhoneNumber, PhoneNumberValidator

    assert PhoneNumber is not None and PhoneNumberValidator is not None


def test_old_module_not_referenced():
    offenders = []
    for p in list((ROOT / 'pydantic_extra_types').rglob('*.py')) + list((ROOT / 'tests').rglob('*.py')):
        if p.name == 'test_study_hidden.py':
            continue
        text = p.read_text()
        if 'pydantic_extra_types.phone_numbers' in text:
            offenders.append(str(p.relative_to(ROOT)))
        for node in ast.walk(ast.parse(text)):
            if isinstance(node, ast.ImportFrom) and node.module == 'pydantic_extra_types' and any(a.name == 'phone_numbers' for a in node.names):
                offenders.append(str(p.relative_to(ROOT)))
    assert offenders == []
