stubtest doesn't expand `**kwargs: Unpack[...]` in overloads

**Bug Report**

#21024 made stubtest expand `**kwargs: Unpack[TypedDict]` for plain functions, but not for overloaded ones.
In django-stubs we are trying to factor the kwargs shared by every `Field.__init__` overload into a TypedDict, to avoid spelling the same ones over and over.


**To Reproduce**

```python
# pkg/__init__.py
def plain(*, a: int = 0, b: int = 0) -> None: ...
def overloaded(x, *, a=0, b=0): ...
```

```python
# pkg/__init__.pyi
from typing import Literal, TypedDict, Unpack, overload, type_check_only

@type_check_only
class KW(TypedDict, total=False):
    a: int
    b: int

def plain(**kwargs: Unpack[KW]) -> None: ...
@overload
def overloaded(x: Literal[True], **kwargs: Unpack[KW]) -> None: ...
@overload
def overloaded(x: bool, **kwargs: Unpack[KW]) -> None: ...
```

```
PYTHONPATH=. MYPYPATH=. stubtest pkg
```


**Expected Behavior**

No errors, like for `plain`.


**Actual Behavior**

```
error: pkg.overloaded is inconsistent, stub does not have parameter "a"
Stub: in file pkg/__init__.pyi:9
Overload(def (x: Literal[True], **kwargs: **TypedDict(pkg.KW, {'a'?: int, 'b'?: int})), def (x: bool, **kwargs: **TypedDict(pkg.KW, {'a'?: int, 'b'?: int})))
Inferred signature: def (x: bool, **kwargs)
Runtime: in file pkg/__init__.py:2
def (x, *, a=0, b=0)

error: pkg.overloaded is inconsistent, stub does not have parameter "b"
...
error: pkg.overloaded is inconsistent, runtime does not have **kwargs parameter "kwargs"
...
Found 3 errors (checked 1 module)
```


**Your Environment**

- Mypy version used: 2.4.0
- Mypy command-line flags: none
- Mypy configuration options from `mypy.ini` (and other config files): none
- Python version used: 3.13
