Move the class `Group` out of `rich/console.py` into a new module `rich/group.py`, so that it is imported as
`from rich.group import Group`. The class must be defined only in `rich/group.py`. Update every place in the code base
that imports `Group` from `rich.console` (the library, the examples and the tests) to import it from its new module.
The `group` decorator stays in `rich/console.py` and must keep returning `Group` objects. Behaviour must not change.
Updating documentation files is optional.
