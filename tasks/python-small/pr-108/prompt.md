complement

I make frequent use of `complement`.

Something like,

```
def complement(f):
    def inner(*args, **kwargs):
        return not f(*args, **kwargs)
    return inner
```

Needed it today and put it in my local toolbelt.
