dropstart dropdown caret renders on the wrong side

Two smaller, unrelated mixin/utility bugs:

- `core/scss/ui/_type.scss:12,15` — `a`/`a:hover` use `color-mix(in sRGB, transparent, var(--link-color) var(--link-opacity, 100%))`, treating `--link-opacity` as a CSS percentage. Everywhere else in the codebase (`.link-opacity-*` utilities, `_reboot.scss`, `utils/_colors.scss`) it's a unitless 0–1 fraction. The moment any `.link-opacity-*` class sets e.g. `--link-opacity: 0.5`, the substituted value isn't a valid `<percentage>`, the whole `color-mix()` becomes invalid, and the browser drops the declaration — links render black instead of their intended color. Verified live in a browser.
- `core/scss/mixins/_functions.scss:22` — `media-breakpoint-down-than($name, $breakpoints)` forwards its `$breakpoints` argument to `breakpoint-max()` but not to the preceding `breakpoint-prev()` call, so the "previous breakpoint" lookup always uses the global `$grid-breakpoints` even when a caller passes a custom map. Currently latent (no real caller passes a custom map today), but will silently misbehave the moment one does.

