Rename the public function `partition_all` (in `toolz/itertoolz.py`) to `chunked`, everywhere it is defined, exported,
re-exported or used in the code base, including the curried namespace, the sandbox and the tests. Do not keep the old
name as an alias. Updating documentation files is optional.
