# Add column selector overload to `GroupBy.sortByKey`

Now you can't specify key columns for sorting in `sortByKey` (all columns are used with the same order). No implementation is needed, need only to add an overload with column selector.

### Problem

`GroupBy.sortByKey` currently sorts by all key columns with the same order.

It is not possible to specify which key columns should be used for sorting.

This limits flexibility when working with grouped data.

### Expected

Allow selecting specific key columns for sorting.

### Proposed solution

Add an overload of `sortByKey` that accepts a column selector.

Example:

`groupBy { a and b }.sortByKey { a }`

### Acceptance criteria

- New overload of `sortByKey` accepts column selector
- Users can specify subset of key columns
- Existing behavior (sorting by all keys) remains unchanged
- Add tests for:
  - sorting by all keys (current behavior)
  - sorting by subset of keys
- Add minimal documentation/example

### Motivation

Sorting grouped data is a common operation.

Lack of column selection makes API less flexible compared to other DSL operations, which already support selectors.

This is a small but important consistency improvement before 1.0.
