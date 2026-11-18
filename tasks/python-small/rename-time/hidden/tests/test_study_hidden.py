import io
import tokenize
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def _names(path):
    with open(path, 'rb') as f:
        toks = list(tokenize.tokenize(io.BytesIO(f.read()).readline))
    # NAME tokens, with the token before each, to tell `Time` from `pendulum.Time`
    return [(t.string, toks[i - 1].string if i else '') for i, t in enumerate(toks) if t.type == tokenize.NAME]


def test_new_name_exists():
    import pendulum

    from pydantic_extra_types import pendulum_dt

    assert not hasattr(pendulum_dt, 'Time')
    assert issubclass(pendulum_dt.PendulumTime, pendulum.Time)
    assert pendulum_dt.PendulumTime.instance(pendulum.time(1, 2, 3)).hour == 1


def test_old_name_only_as_pendulum_time():
    offenders = []
    for p in ROOT.rglob('*.py'):
        if p.name == 'test_study_hidden.py' or '.git' in p.parts:
            continue
        for name, prev in _names(p):
            if name == 'Time' and prev != '.' and not (p.name == 'pendulum_dt.py' and prev == 'import'):
                offenders.append(str(p.relative_to(ROOT)))
    assert offenders == []


def test_pendulum_alias_untouched():
    src = (ROOT / 'pydantic_extra_types' / 'pendulum_dt.py').read_text()
    assert 'from pendulum import Time as _Time' in src
