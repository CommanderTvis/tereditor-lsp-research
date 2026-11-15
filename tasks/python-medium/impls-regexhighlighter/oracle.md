# Oracle: transitive subclasses of rich.highlighter.RegexHighlighter

Derived without a language server: an exhaustive text candidate list, classified by hand.

    rg -n 'RegexHighlighter' -g '*.py'                     # 10 lines at the pinned commit
    rg -n '^\s*class \w+\(' -g '*.py' | rg 'ReprHighlighter|JSONHighlighter|ISO8601Highlighter|PathHighlighter|RequestHighlighter|EmailHighlighter|highlighter\.'

The first search gives the direct subclasses (`class X(RegexHighlighter)` statements): `ReprHighlighter`,
`JSONHighlighter`, `ISO8601Highlighter` (rich/highlighter.py), `PathHighlighter` (rich/traceback.py),
`RequestHighlighter` (examples/log.py), `EmailHighlighter` (examples/highlighter.py). Its other lines are the
definition (rich/highlighter.py:61) and imports (rich/traceback.py:42, examples/log.py:9, examples/highlighter.py:6).
The second search, over every class statement whose bases name one of those six or reach a base through a module
attribute, finds no further level: no class in the repository subclasses any of the six, and no class names
`highlighter.RegexHighlighter` as a base. The selection script (select.py, an ast walk) gives the same six.

Excluded: `NullHighlighter` (rich/highlighter.py:50) and `RainbowHighlighter` (examples/rainbow.py:13) inherit from
`Highlighter` directly. Classes in documentation files (.rst/.md) are not Python files and are out of scope.

Judgement calls: none.
