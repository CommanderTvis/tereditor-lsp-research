# Make GroupBy.sortBy and sortByDesc sort rows within groups only

## Problem

`GroupBy.sortBy` and `GroupBy.sortByDesc` are documented as operations that sort rows within each group.

The public documentation distinguishes them from operations that change the order of key-group pairs:

- `sortBy` / `sortByDesc` — sort rows within each group;
- `sortByKey` / `sortByKeyDesc` — sort key-group pairs by key values;
- `sortByGroup` / `sortByGroupDesc` — sort key-group pairs by values computed from groups;
- `sortByCount` / `sortByCountAsc` — sort key-group pairs by group size.

However, the current implementation applies the same selector twice:

1. to every group;
2. to the outer grouped dataframe containing the keys and the frame column.

As a result, selecting a grouping key in `sortBy` also changes the order of the groups:

```kotlin
val grouped = dataFrameOf(
    "key", "value",
)(
    "b", 2,
    "b", 1,
    "a", 4,
    "a", 3,
).groupBy("key")

val result = grouped.sortBy("key")
```

Currently, `result` changes the outer group order from `["b", "a"]` to `["a", "b"]`, even though `sortBy` is documented as sorting rows inside groups.

Inside each group, sorting by `key` has no observable effect because all rows have the same key.

This behaviour overlaps with `sortByKey` and makes the meaning of `GroupBy.sortBy` ambiguous.

## Expected behaviour

GroupBy.sortBy and GroupBy.sortByDesc should sort rows only within each group, preserving the order of key–group pairs.

They should not change the order of key-group pairs.

For example:

```kotlin
val sorted = grouped.sortBy("value")
```

should:

- sort the rows inside the `"b"` group from `[2, 1]` to `[1, 2]`;
- sort the rows inside the `"a"` group from `[4, 3]` to `[3, 4]`;
- preserve the outer group order `["b", "a"]`.

Likewise:

```kotlin
grouped.sortBy("key")
```

should preserve the outer group order. To sort the groups by their keys, users should call:

```kotlin
grouped.sortByKey()
```

## Definition of done

- `GroupBy.sortBy` sorts rows inside groups only.
- `GroupBy.sortByDesc` sorts rows inside groups only.
- Neither operation changes the order of key-group pairs.
- `sortByKey`, `sortByKeyDesc`, `sortByGroup`, and `sortByCount` retain their current behaviour.
- Add regression tests covering:
  - ascending and descending sorting inside groups;
  - preservation of the original outer group order;
  - selection of a grouping key in `sortBy`;
  - sorting by multiple columns and sort flags.
- Update the KDoc and website documentation if necessary to make the separation between inner-row sorting and key-group sorting explicit.
