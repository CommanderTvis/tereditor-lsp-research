# Mined pull requests: python-small (toolz)

Candidates from `sh harness/gen/mine-prs.sh python-small` (11 qualify), taken strictly in the order of
`pr-candidates.jsonl`. Each was checked with CPython 3.12 and pytest (the `grade-python` toolchain): the pull
request's test files at its merge applied to its base commit must fail, and pass with its non-test change.
Fail-to-pass = tests passing after and not before; pass-to-pass = tests of the changed test files passing both before
and after. Tests that fail both before and after on CPython 3.12 (old code using APIs removed from Python) are in
neither list. A candidate is skipped when it has no fail-to-pass test on CPython 3.12, or its test files cannot be
collected after the change.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #78 | #77 Remove is not lazy | skipped: no fail-to-pass test on CPython 3.12 (`filter` is already lazy on Python 3; the bug was Python 2 only) |
| 2 | #108 | #43 complement | task `pr-108` (6 fail-to-pass; 8 curry tests of the file fail before and after: `inspect.getargspec` is gone in 3.12) |
| 3 | #355 | #725 Can't pickle function delayed | skipped: needs an older Python (`toolz/functoolz.py` at the base has a SyntaxError on 3.12: unparenthesised generator argument); the linked issue is also a dask issue |
| 4 | #15 | #14 Currying standard functions | skipped: needs an older Python (`toolz/tests/test_curried.py` cannot be collected after the change: `inspect.getargspec`) |
| 5 | #9 | #6 Add assoc and update_in to dicttoolz | task `pr-9` (5 fail-to-pass: the test module imports the new functions) |
| 6 | #399 | #387 `partition_all` fails for sequence of `pd.DataFrame`s | task `pr-399` (1 fail-to-pass, 46 pass-to-pass; `test_nth` and `test_random_sample` fail before and after on 3.12) |

Stopped at three valid tasks; candidates 7 to 11 were not examined.
