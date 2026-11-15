The mixin `focusOutline` in `src/support/mixins/misc.scss` takes `($outlineOffset, $outlineColor)`. Reorder its
parameters to `($outlineColor, $outlineOffset)`, keeping both defaults as they are, and update every place that
includes it so that the compiled CSS of every bundle stays exactly the same. Do not add a second mixin or a wrapper
with the old order.
