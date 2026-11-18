Move Labs' DatePicker into Core as `Preview`

- Pull the code over from labs into core
- Expose it as `Preview` in both `@carbon/react` and `@carbon/web-components`
- Follow preview code conventions - `preview__DatePicker`, Preview sections in storybook, etc.
- The code in `@carbon-labs/primitives` in labs should be moved into the existing `utilities` package in core. We should not create a new `primitives` package. 
- This will require some refactoring of code to fit the labs' modules into `@carbon/utilities` in a way that makes sense.

This work _does not_ have to cover all bases, there is a separate issue for moving this to stable and meeting our definition of done.

* #22433

The initial drop must include migration documentation, instructing teams how to migrate and what to watch out for. I don't think we expose any flatpickr internals, so that might not be a concern? https://github.com/carbon-design-system/carbon/blob/5bb41d341768785b898851fde30731cb31b981c2/packages/react/src/components/DatePicker/DatePicker.tsx#L603-L661
