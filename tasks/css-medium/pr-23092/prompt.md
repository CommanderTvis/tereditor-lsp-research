Move new Tearsheet React component to core

Let start the migration to core with new Tearsheet and identify the challenges


### Observations
In order to migrate tearsheet to core, we need to move below dependant components first

- [ ] TruncatedText
- [ ] SidePanel
- [ ] ActionSet

## Summary

Migrate `Tearsheet` (composable) from `carbon-for-ibm-products` into the Carbon core monorepo.

**c4ip export name:** `Tearsheet`
**Target status:** Stable
**Notes:** Old monolithic `Tearsheet` deprecated; new composable version already delivered in c4ip as a preview. Migrating to core as **stable**.

Parent epic: #22655

---

## Checklist

- [ ] Update prefix: replace `pkg.prefix (c4p)` with `usePrefix() (cds)`
- [ ] Update imports: migrate from `@carbon/react` to local paths
- [ ] Migrate shared utilities: move any missing utilities to `packages/react/src/internal/` first
- [ ] Rename test file: `Tearsheet.test.jsx` → `__tests__/Tearsheet-test.js`
- [ ] Update tests: fix mocks, remove ibm-products-only matchers, and ensure tests pass
- [ ] Rename stories file: `.stories.jsx` → `.stories.js`, and convert from CSF2 to CSF3
- [ ] Update stories: use `story.scss` with the decorator pattern, and remove `parameters.styles`
- [ ] Rename SCSS folder: `Tearsheet/` → `tearsheet/`
- [ ] Migrate styles: move to `packages/styles/scss/components/tearsheet/`
- [ ] Remove ibm-products-specific SCSS files: `_carbon-imports.scss`, `_index-with-carbon.scss`
- [ ] Register styles: add `@use 'tearsheet'` to `packages/styles/scss/components/_index.scss`
- [ ] Export component: add it to `packages/react/src/index.ts`
- [ ] Update index snapshot: include it in `packages/react/src/__tests__/index-test.js`
- [ ] Fix MDX docs: remove ibm-products imports and add `<Meta isTemplate />`
- [ ] Migrate relevant avt tests
- [ ] Strip out the proptypes (rely on [types](https://github.com/carbon-design-system/carbon/issues/22384))
- [ ] Migrate figma files
- [ ] Ensure open in stackblitz works

## How to verify

- Perform manual testing in v12 storybook and ensure nothing is breaking
- Ensure avts are migrated and passing
- **Verify the changes are intended:**
  - Delete the components folder from ibm-products repo
  - Copy the migrated component folder with all the migration changes back to products repo
  - Verify the changes in git source control in the IDE
  - Copy the newly generated style folder from carbon to ibm-products repo and compare styles to ensure no unintended styles have been added or removed

