Bug report: asking for several positions with a default no longer fills in the default when a position is past the end
of a sequence. `toolz.get([0, 5], 'AB', default=None)` raises `IndexError` instead of returning `('A', None)`, and
`list(toolz.pluck([0, 3], [[1, 2]], default=None))` raises instead of returning `[(1, None)]`. Missing keys in
dictionaries still get the default as expected.

Find the cause and fix it in the library code. Keep the change minimal.
