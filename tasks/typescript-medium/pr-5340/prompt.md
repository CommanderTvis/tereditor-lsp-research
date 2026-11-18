# jsx/dom: improve keyed children reconciliation for large list updates

## What is the feature you are proposing?

I would like to improve the reconciliation performance of large keyed child lists in `hono/jsx/dom`.

The current reconciliation logic searches the existing children array with `findIndex()` and removes matched children with `splice()`.

This is not an issue for small lists, but it can scale poorly when large tables or log viewers handle selection, filtering, sorting, or reordering.

## Use case

For example, a parent component may manage both table rows and selection state:

```tsx
const [rows, setRows] = useState(initialRows)
const [selectedIds, setSelectedIds] = useState<string[]>([])

return (
  <>
    <button onClick={() => setSelectedIds([])}>
      Clear selection
    </button>

    <table>
      <tbody>
        {rows.map((row) => (
          <Row key={row.id} row={row} />
        ))}
      </tbody>
    </table>
  </>
)
```

Changing only the selection state causes the parent component to run again, so `rows.map()` creates the keyed children again.

Reordering also changes the DOM order in real applications:

```tsx
setRows((rows) => [...rows].reverse())
```

These patterns occur in data tables, log viewers, file lists, chat histories, and drag-and-drop interfaces.

## Current behavior

In a local Bun benchmark with 5,000 keyed elements, the current implementation produced:

- approximately 12.5 million array movements even when the order did not change
- approximately 12.5 million key comparisons when reversing the list
- approximately 12.5 million array movements when swapping the first and last elements

These numbers do not represent browser wall-clock time directly, but they show that the amount of reconciliation work can grow quadratically for large keyed lists.

## Expected behavior

Please reduce unnecessary linear searches and array operations during keyed-child reconciliation while preserving existing DOM elements and component state.

Possible approaches include:

- using an index structure that can efficiently find existing children by key
- avoiding repeated `splice()` operations on the old children array
- reusing the child at the current position when its key already matches
- keeping the additional overhead low for small lists

The implementation approach is not intended to be prescriptive. The important requirements are to preserve current DOM identity and state behavior.

## Compatibility requirements

The following behavior should remain unchanged:

- DOM element identity
- component state
- `ref` and effect cleanup
- focus and selection
- fragments
- controlled form values
- reconciliation behavior for unkeyed children
- current behavior for duplicate keys

This is a performance improvement for updates involving large keyed child lists, not a behavior change.
