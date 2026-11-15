import importlib
import importlib.util

import toolz
import toolz.curried
import toolz.recipes
import toolz.sandbox.core
import toolz.sandbox.parallel


def test_new_module():
    m = importlib.import_module('toolz.sequences')
    assert m.get is toolz.get
    assert m.partition_all is toolz.partition_all
    assert toolz.curried.first is m.first
    assert m.__file__.endswith('sequences.py')


def test_old_module_gone():
    assert importlib.util.find_spec('toolz.itertoolz') is None
    assert not hasattr(toolz, 'itertoolz')


def test_dependents_still_work():
    assert toolz.recipes.countby(len, ['a', 'bb', 'cc']) == {1: 1, 2: 2}
    assert toolz.sandbox.parallel.fold(lambda a, b: a + b, list(range(10)), 0, chunksize=3) == 45
    assert list(toolz.sandbox.core.unzip([(1, 2), (3, 4)])[0]) == [1, 3]
