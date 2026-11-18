# F#: option and single-case union columns refused as divergent storage next to plain columns

### Summary

Since #5902, a query that combines an F# `option` / `voption` or single-case-union column with a column that has no
converter (or a different one) fails to translate with "their value converters do not agree on what a stored value
counts", although both columns store the same value.

### Background

#5902 (milestone 6.5.1, not yet released) refuses an operator, a conditional or a set operation between two values
whose value converters differ, because two different conversions make the stored values incommensurable. LinqToDB.FSharp
maps every scalar option and single-case-union member through a value converter, but that converter stores the payload
unchanged: `Some v` is stored as `v` and `None` as `NULL`; `UserId 10` is stored as `10`.

### Current behavior

`SequenceHelper.ConvertTheSameWay` treats "converter vs no converter" and any two converters that are not equal as
divergent, so an option column next to a plain column is refused:

- `Source/LinqToDB/Internal/Linq/Builder/SequenceHelper.cs:60` — `ConvertTheSameWay` returns false when one side has a converter
- `Source/LinqToDB/Internal/Linq/Builder/ExpressionBuildVisitor.cs` — `CombinesDivergentStorage` / `CanShareOneReading` refuse with `Error_ValueConverter_DivergentOperands`
- `Source/LinqToDB.FSharp/FSharpOptionSupport.fs:84`, `Source/LinqToDB.FSharp/FSharpSingleCaseUnionSupport.fs:38` — the converters

```fsharp
type OptRow = { [<PrimaryKey>] Id: int; Age: int option }
db.GetTable<OptRow>().Where(fun x -> x.Age.Value = x.Id)
```

fails on SQLite.MS (direct and remote) with:
`Cannot combine 'Age' and 'Id' in the database: their value converters do not agree on what a stored value counts ...`

The same refusal hits `x.OptKey.Value = x.Key` (`UserId option` vs `UserId`: two different converters) and an
association over an `option` foreign key, whose generated predicate is `x.ParentId.Value == a_Parent.Id` (found by the
scaffold codegen harness for F# scaffolded models).

### Expected behavior

These comparisons translate to plain column comparisons, as before #5902. Converters that actually change the stored
value keep being refused.

### Notes

- Related, separate: #5886 (an option `.Value` compared with a literal passes the unconverted element as a parameter).
- Reproduced and fixed on the #5707 branch; the fix will be its own PR on top of master.

