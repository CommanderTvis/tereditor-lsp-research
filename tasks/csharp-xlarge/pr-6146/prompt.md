# SQLite: string.Join over object items concatenates an arithmetic item without parentheses

### Summary

On SQLite, `string.Join` over `object` items renders an arithmetic item as a bare operand of `||`. SQLite binds `||` tighter than `+`, so the rest of the joined string is added to the item's last operand, and the result is a number.

### Background

SQLite lists `||` above `* / %` and `+ -` in its operator table, "listed in precedence order (top to bottom / highest to lowest)": https://www.sqlite.org/lang_expr.html#operators

### Current behavior

```cs
[Table]
sealed class JoinProbeEntity
{
	[PrimaryKey] public int Id     { get; set; }
	[Column]     public int Value1 { get; set; }
}

using var db    = GetDataContext(context); // SQLite.Classic or SQLite.MS
using var table = db.CreateLocalTable(new[] { new JoinProbeEntity { Id = 1, Value1 = 10 } });

table.Select(e => string.Join(",", new object[] { e.Value1 + 1, e.Value1 })).ToArray();
// expected: "11,10"
// actual:   "11"
```

```sql
SELECT
	[e].[Value1] + 1 || ',' || [e].[Value1]
FROM
	[JoinProbeEntity] [e]
```

SQLite evaluates it as `[e].[Value1] + (1 || ',' || [e].[Value1])`, i.e. `10 + '1,10'`, which is `11`.

- `Source/LinqToDB/SqlQuery/Precedence.cs:16-23` — `Concatenate = 5`, below every other operator. The comment describes it as defensive: a concat nested in another operator gets parentheses. The reverse case, an arithmetic operand inside a concat, is left bare, which changes the result wherever `||` binds tighter than `+`.
- `Source/LinqToDB/Internal/DataProvider/SQLite/Translation/SQLiteMemberTranslator.cs:281-346` — SQLite's `TranslateStringJoin`; an inline array goes through `ConfigureConcatWsEmulation` (`:334`).

`string.Concat(new object[] { ... })` over the same items is correct: it casts each item (`CAST([e].[Value1] + 1 AS NVarChar(11))`), which keeps the arithmetic inside the cast.

### Expected behavior

`"11,10"`: the arithmetic item parenthesized (`([e].[Value1] + 1) || ','`) or converted to text the way `string.Concat` does it.

### Notes

- Related: #5527 (the precedence table is provider-agnostic). This is a wrong-result case rather than redundant brackets.
- Found while writing tests for #5932, but independent of it: it reproduces without any outer join, and `Precedence.cs` and `Internal/DataProvider/SQLite` are unchanged between master `7c5d5b5ae8` and that branch.
- Not checked on other providers. Not pinned: why the `string.Join` item path emits no cast where `string.Concat` does.

