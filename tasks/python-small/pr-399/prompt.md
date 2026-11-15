`partition_all` fails for sequence of `pd.DataFrame`s

```
In [33]: list(partition_all(2, [pd.DataFrame()]))
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-33-f36c7ec14356> in <module>()
----> 1 list(partition_all(2, [pd.DataFrame()]))

~/miniconda3/envs/model/lib/python3.6/site-packages/toolz/itertoolz.py in partition_all(n, seq)
    720         prev = item
    721     if prev[-1] is no_pad:
--> 722         yield prev[:prev.index(no_pad)]
    723     else:
    724         yield prev

~/miniconda3/envs/model/lib/python3.6/site-packages/pandas/core/generic.py in __nonzero__(self)
   1119         raise ValueError("The truth value of a {0} is ambiguous. "
   1120                          "Use a.empty, a.bool(), a.item(), a.any() or a.all()."
-> 1121                          .format(self.__class__.__name__))
   1122
   1123     __bool__ = __nonzero__

ValueError: The truth value of a DataFrame is ambiguous. Use a.empty, a.bool(), a.item(), a.any() or a.all().
```
Works fine when the chunks are all of equal size. Similarly `(pd.DataFrame(), 'a').index('a')` fails for the same reason. Is there an equivalent way to do this check in `itertoolz.py:722` w/o `.index()`?
