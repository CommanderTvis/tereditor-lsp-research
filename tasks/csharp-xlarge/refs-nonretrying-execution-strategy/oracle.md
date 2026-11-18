# Oracle: refs of NonRetryingExecutionStrategy

Not derived from a language server. Exhaustive whole-word text candidate list at the pinned commit
(`rg -nw NonRetryingExecutionStrategy .`, 16 lines), then classified by hand:

- Kept (10): the declaration (line 21), the two constructor declarations (27, 34) and the seven code uses
  (ExecutionStrategyFactory.cs 14 and 23, RelationalExecutionStrategyFactory.cs 49, four SQL Server test files).
- Excluded: three `<see cref>` doc-comment mentions in NonRetryingExecutionStrategy.cs (lines 24, 31, 40), and three lines of
  src/EFCore/EFCore.baseline.json (not C#).

The name is unique (no other symbol of that name), so no judgement call about collisions was needed.
