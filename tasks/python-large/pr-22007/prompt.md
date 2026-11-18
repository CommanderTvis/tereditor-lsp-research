Overloaded function as a subtype of function with union types args/return

This code should probably be valid:

``` python
from typing import Callable, Union, overload

def f(fn: Callable[[Union[int, str]], Union[int, str]]) -> None: pass

@overload
def g(x: int) -> int: ...
@overload
def g(x: str) -> str: ...
def g(x): ...

f(g)   # Currently error
```

I.e., an overloaded function should be a subtype of a suitable function with union type arguments and return value.
