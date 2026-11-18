# Oracle: subtypes of DefaultCellComponentProps

Derived without a language server: an exhaustive text search over the pinned tree, checked by hand,

    git grep -nP "(interface|class)\s+\w+[^{;=]*extends\s+[^{]*DefaultCellComponentProps" -- . ':!docs'
    git grep -n "DefaultCellComponentProps" -- packages test templates examples

- `ArrayCellProps`, `BlocksCellProps`, `CodeCellProps`, `SelectCellProps` (single-line declarations) and `FileCellProps`
  (multi-line generic, packages/ui/src/elements/Table/DefaultCell/fields/File/index.tsx:17) are the only declarations
  with `extends DefaultCellComponentProps`; no interface or class extends any of those five, so the set is closed.
- Not counted by the prompt's rules: `HierarchyCellProps`, `RelationshipCellProps`, `StatusCellProps` (type aliases),
  `PriceCell` props (intersection in packages/plugin-ecommerce) and the `React.FC<DefaultCellComponentProps<...>>`
  cell components.

Judgement calls: the alias/intersection exclusion is stated in the prompt.
