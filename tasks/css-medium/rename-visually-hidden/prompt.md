Rename the Sass mixin `visually-hidden`, defined in `packages/styles/scss/utilities/_visually-hidden.scss`, to
`screen-reader-only`, and update every place that includes it, in every package of this repository, however the
include is written (with or without a module namespace).

Only the mixin is renamed. The partial `_visually-hidden.scss` keeps its name, so every `@use` and `@forward` path that
points at it stays as it is, and the CSS class `.cds--visually-hidden` (and every other selector that merely contains
the words) must not change. The compiled CSS of every stylesheet must stay exactly the same. Do not keep the old mixin
as an alias.
