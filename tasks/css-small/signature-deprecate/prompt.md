The mixin `deprecate` in `core/scss/mixins/bootstrap/_deprecate.scss` takes
`($name, $deprecate-version, $remove-version, $ignore-warning: false)`. We want the version first:

    @mixin deprecate($deprecate-version, $name, $remove-version, $ignore-warning: false)

Change the mixin and update every place that includes it, so that the stylesheets compile to exactly the same CSS and the
messages stay the same. Do not add a second mixin or a wrapper with the old order.
