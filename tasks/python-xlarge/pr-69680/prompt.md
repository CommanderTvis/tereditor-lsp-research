[BUG] Byte conversion factors off by power of 10 in _parse_numbers() in modules/disk.py

**Description**

I was looking at [`salt/modules/disk.py`](https://github.com/saltstack/salt/blob/master/salt/modules/disk.py) and came across the following in the definition of [`_parse_numbers`](https://github.com/saltstack/salt/blob/master/salt/modules/disk.py#L32):

https://github.com/saltstack/salt/blob/93b640543c3d404d7b19d760f5f83a65ee936d67/salt/modules/disk.py#L42-L51

It seems to me that these are all off by a factor of 10: `K` should be `1E3`, not `10E3`, and so on.

This function seems to only be used by the `_iostat_aix()` function, so I don't know how large the impact is, or whether this may even be expected behavior on AIX platforms.

**Example**

I loaded the definition of `_parse_numbers` into an interpreter to play around with it. As noted, it seems to me that these values are off by a factor of 10:

```python
>>> float(_parse_numbers("1.0K"))
10000.0
# I would expect 1000.0

>>> float(_parse_numbers("32.8K"))
328000.0
# I would expect 32800.0
```

**Suggested fix**

Remove the extra `0` characters. I also recommend replacing the `E` with `e`, which helps distinguish the numbers from the `e` more easily (when written with a lowercase `e`, the current `10e3` value looks very suspect, especially next to the `K` suffix).

```python
postPrefixes = {
    "K": "1e3",
    "M": "1e6",
    "G": "1e9",
    "T": "1e12",
    "P": "1e15",
    "E": "1e18",
    "Z": "1e21",
    "Y": "1e24",
}
```

As a separate note, `postPrefixes` is IMO a poor name and should be renamed `unit_to_bytes` or `unit_suffixes` or something more clear, although that is unrelated to the issue at hand.
