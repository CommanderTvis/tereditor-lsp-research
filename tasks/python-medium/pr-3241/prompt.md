False positive `unbalanced-tuple-unpacking` when unpacking an exception's `args`

### Bug description

astroid models `BaseException.args` on an exception instance as a *known empty* tuple (`ExceptionInstanceModel.attr_args` returns `nodes.Tuple()` with no elements). Pylint's `unbalanced-tuple-unpacking` therefore reports "right side has 0 values" whenever code unpacks `exc.args`, even though the length of `args` is simply unknown.

The stdlib does this in `importlib/metadata/__init__.py`:

```python
class PackageNotFoundError(ModuleNotFoundError):
    @property
    def name(self) -> str:
        (name,) = self.args
        return name
```

Minimal example:

```python
def f():
    try:
        pass
    except ValueError as exc:
        (message,) = exc.args
        first, second = exc.args
        return message, first, second
    return None
```

### Configuration

_No response_

### Command used

```shell
pylint --disable=all --enable=unbalanced-tuple-unpacking a.py
```

### Pylint output

```shell
************* Module a
a.py:5:8: W0632: Possible unbalanced tuple unpacking with sequence : left side has 1 label, right side has 0 values (unbalanced-tuple-unpacking)
a.py:6:8: W0632: Possible unbalanced tuple unpacking with sequence : left side has 2 labels, right side has 0 values (unbalanced-tuple-unpacking)
```

### Expected behavior

No message. The contents of `args` are not known from the instance alone, so the check cannot say the unpacking is unbalanced.

### Pylint version

```shell
pylint 4.1.0-dev0
astroid 4.4.0-dev0
Python 3.13.11
```

### OS / Environment

macOS

### Additional dependencies

_No response_
