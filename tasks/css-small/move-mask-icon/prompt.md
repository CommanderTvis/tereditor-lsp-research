Move the mixin `mask-icon` out of `core/scss/mixins/_mixins.scss` into a new partial of its own,
`core/scss/mixins/_mask-icon.scss`. Afterwards the mixin is defined only in the new file, the stylesheets that use it
(through `@use '../config' as *`) must still get it, and the compiled CSS of every entry point of `core/scss` must stay exactly
the same. Do not change the mixin itself.
