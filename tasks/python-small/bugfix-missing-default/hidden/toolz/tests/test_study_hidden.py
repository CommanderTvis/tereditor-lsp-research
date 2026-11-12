from toolz import get, pluck
from toolz.curried import get as cget


def test_get_list_default_index_out_of_range():
    assert get([0, 5], 'AB', default=None) == ('A', None)
    assert get([0, 5], ['a', 'b'], 'X') == ('a', 'X')


def test_pluck_list_default_index_out_of_range():
    assert list(pluck([0, 3], [[1, 2], [3, 4, 5, 6]], default=None)) == [(1, None), (3, 6)]


def test_get_list_default_missing_key_still_works():
    assert get(['a', 'z'], {'a': 1}, default=0) == (1, 0)
    assert cget([1, 9], default='-')('xy') == ('y', '-')
