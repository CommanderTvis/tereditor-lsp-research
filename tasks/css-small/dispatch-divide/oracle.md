# Oracle: which `divide` runs at core/scss/mixins/bootstrap/_rfs.scss:114

Derived with the repository's own sass (dart-sass 1.108.1), not with a language server: both definitions were instrumented to
warn with their file and the dividend, a probe call `divide(777771, 1)` was inserted in the same scope as the line in
question (before line 114, inside the `@if`), another probe `divide(777772, 1)` before `_variables.scss:430`, and
`core/scss/tabler.scss` was compiled:

    WARNING: STUDY-DEF rfs 777771        (the call in _rfs.scss reaches the definition in _rfs.scss, line 60)
    WARNING: STUDY-DEF functions 777772  (the call in _variables.scss reaches mixins/_functions.scss, line 290)

`_rfs.scss` does not load `mixins/functions`: it uses its own copy (line 60), and `core/scss/_mixins.scss` hides that copy
(`@forward 'mixins/bootstrap/rfs' hide divide`) from everything downstream. The branch at line 114 runs with the default
`$rfs-breakpoint: 1200px`. No judgement call.
