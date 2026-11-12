import toolz
import toolz.curried
import toolz.itertoolz
from toolz.sandbox import parallel


def test_new_name_everywhere():
    assert list(toolz.chunked(2, [1, 2, 3])) == [(1, 2), (3,)]
    assert list(toolz.itertoolz.chunked(2, [1, 2, 3])) == [(1, 2), (3,)]
    assert list(toolz.curried.chunked(2)([1, 2, 3])) == [(1, 2), (3,)]
    assert 'chunked' in toolz.itertoolz.__all__


def test_old_name_gone():
    for mod in (toolz, toolz.itertoolz, toolz.curried):
        assert not hasattr(mod, 'partition_all'), mod
    assert 'partition_all' not in toolz.itertoolz.__all__


def test_parallel_fold_still_works():
    assert parallel.fold(lambda a, b: a + b, list(range(100)), 0, chunksize=7) == sum(range(100))
