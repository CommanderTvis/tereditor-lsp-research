`DefaultCellComponentProps` (declared in `packages/payload/src/admin/elements/Cell.ts`) is the props type that
custom table-cell components receive. I am about to change it and need to know which other types are built on it.

List every interface or class under `packages/` that is declared with `extends` of `DefaultCellComponentProps`
(directly, or through another type that extends it). Do not count a type alias that merely uses it
(`type X = DefaultCellComponentProps<...>`), an intersection (`& DefaultCellComponentProps`), a function component
typed `React.FC<DefaultCellComponentProps<...>>`, or anything under `test/`, `templates/`, `examples/` or `docs/`.

Write the result to `ANSWER.txt` in the repository root, one type name per line (for example `ArrayCellProps`).
