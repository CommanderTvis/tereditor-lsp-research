Literal[True, False] false positives within tuples

This code generates unexpected errors:

```py
from typing import NamedTuple, Literal, List, Tuple

C = NamedTuple("C", [("x", Literal[True, False])])

T = Tuple[Literal[True, False]]

# Incompatible types in assignment (expression has type "List[C]", variable has type "List[C]")
x: List[C] = [C(True)]

t: T

# Incompatible types in assignment (expression has type "List[Tuple[bool]]", 
# variable has type "List[Tuple[Union[Literal[True], Literal[False]]]]")
y: List[T] = [t]
```

The issue was introduced in #10389.

Marking as high priority since this is a regression.

cc @ethan-leba 
