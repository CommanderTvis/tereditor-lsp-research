Unhandled validation error when parsing Color

Missing TypeError handling when validating Color

```python
>>> from pydantic_extra_types.color import Color
>>> Color(({}, 0, 0))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/Users/ilias/projects/my/pydantic-extra-types/pydantic_extra_types/color.py", line 75, in __init__
    self._rgba = parse_tuple(value)
  File "/Users/ilias/projects/my/pydantic-extra-types/pydantic_extra_types/color.py", line 251, in parse_tuple
    r, g, b = (parse_color_value(v) for v in value)
  File "/Users/ilias/projects/my/pydantic-extra-types/pydantic_extra_types/color.py", line 251, in <genexpr>
    r, g, b = (parse_color_value(v) for v in value)
  File "/Users/ilias/projects/my/pydantic-extra-types/pydantic_extra_types/color.py", line 356, in parse_color_value
    color = float(value)
TypeError: float() argument must be a string or a real number, not 'dict'
```
