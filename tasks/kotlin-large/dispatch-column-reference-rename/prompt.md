`ColumnReference` (`core/src/main/kotlin/org/jetbrains/kotlinx/dataframe/columns/ColumnReference.kt`) declares `public fun rename(newName: String): ColumnReference<C>` (line 28), and many column types implement or refine it.

Consider a call `ref.rename("x")` where `ref` is statically a `ColumnReference<*>` and the object it holds is a `ResolvingColumnGroup` (`org.jetbrains.kotlinx.dataframe.impl.columns.ResolvingColumnGroup`). Which function runs?

Write the answer to `ANSWER.txt` in the repository root as one line, `path:line`: the path of the source file that defines that function, relative to the repository root, and the line of its definition on which the function's name appears.
