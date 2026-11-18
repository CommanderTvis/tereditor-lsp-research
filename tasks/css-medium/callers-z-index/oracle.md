# Oracle: which component indexes evaluate a call of `z`

Derived with dart-sass (the study's `grade-css` toolchain), not with a language server: the function is instrumented and
every component is compiled alone.

    # in a copy of the snapshot with the grading overlay (node_modules, built @carbon packages):
    sed -i "s|^@function z(\$layer) {|@function z(\$layer) {\n  @warn 'study-called';|" packages/styles/scss/utilities/_z-index.scss
    for c in $(ls packages/styles/scss/components); do [ -f packages/styles/scss/components/$c/_index.scss ] || continue
      echo "@use \"packages/styles/scss/components/$c\";" | sass --stdin --load-path=. --load-path=node_modules --quiet-deps --no-source-map >/dev/null 2>err
      grep -q study-called err && echo packages/styles/scss/components/$c/_index.scss
    done

89 component directories have an `_index.scss`; 39 emit the warning (no compilation failed). Judgement calls: the
default configuration is what counts (a call behind `@if enable-v12-release` or another off-by-default flag does not
count); a component that only loads another component that calls `z` counts (the prompt says so). Text search for
`z(` finds the 11 components that write a call themselves (including the namespaced form `utilities.z(`), but misses the components that reach
`z` through the shared mixins of `utilities/_tooltip.scss` and through other components.
