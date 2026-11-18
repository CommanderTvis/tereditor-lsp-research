Rename the Sass partial `packages/styles/scss/utilities/_skeleton.scss` to `_skeleton-animation.scss` (the mixin inside
it keeps its name), and update everything that refers to it: every `@use` and `@forward` of its module path in every
package, the list of public Sass entry points of `@carbon/styles` and the documentation that names the path.

The stylesheets in `packages/react`, `packages/carbon-components` and `packages/carbon-components-react` that forward
to it are public entry points of those packages: they keep their own file names and only change what they forward to.
The compiled CSS of every stylesheet must stay exactly the same. Nothing may remain at the old path and no
forwarding stub is wanted there.
