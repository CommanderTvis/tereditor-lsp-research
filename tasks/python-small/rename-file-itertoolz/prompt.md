Rename the module `toolz/itertoolz.py` to `toolz/sequences.py`, so that it is imported as `toolz.sequences`. Update
every import and every reference to the module in the code base, including the sandbox and the tests. Do not leave a
`toolz/itertoolz.py` shim or alias module behind. The public functions themselves (`toolz.groupby`, `toolz.get`, ...)
keep their names and stay available from `toolz` and `toolz.curried`. Updating documentation files is optional.
