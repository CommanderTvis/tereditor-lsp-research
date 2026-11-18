.real and .imag on complex, float, int and bool values compile to generic attribute lookups

Reading `.real` or `.imag` from a value typed as `int`, `float`, `complex`, or a union of them compiles to a generic attribute lookup by name. Each access returns a Python object (often a newly allocated `float`), which is then unboxed or type-checked again:

```python
def parts(z: complex) -> tuple[float, float]:
    return z.real, z.imag
```

```
r0 = 'real'
r1 = CPyObject_GetAttr(z, r0)
r2 = unbox(float, r1)
r3 = 'imag'
r4 = CPyObject_GetAttr(z, r3)
r5 = unbox(float, r4)
```

Native `int`, `bool` and `float` values are boxed first, only to read back the same value (`.real`) or zero (`.imag`).

This comes up in numeric code that accepts several kinds of numbers, for example:

```python
if isinstance(x, (int, float, complex)):
    real, imag = x.real, x.imag
```

Most of these reads don't need the lookup:

- On native `int`, `bool` and `float` values, `x.real` is the value itself (as an `int` for a `bool`) and `x.imag` is zero.
- When the result is a `float`, exact `float`, `complex` and `int` objects can be read directly as a C double. (An `int` can be passed where a `complex` is expected.)
- When the result can be an `int` (for example with `int | float | complex`), `int.real` and `float.real` return the object itself, and exact `complex` objects can be read directly.

Anything else, such as subclasses that override the properties, would keep using the generic lookup.
