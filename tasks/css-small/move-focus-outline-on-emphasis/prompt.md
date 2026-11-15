Move the mixin `focusOutlineOnEmphasis` out of `src/support/mixins/misc.scss` into a new partial of its own,
`src/support/mixins/focus-outline-on-emphasis.scss`. Afterwards it must be defined only in the new file, every
stylesheet that uses it must still get it, and the compiled CSS of every bundle (`src/**/index.scss`) must stay
exactly the same. Do not change the mixin itself.
