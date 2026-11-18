`PersistentSet` (`platforms/core-runtime/collections/src/main/java/org/gradle/internal/collect/PersistentSet.java`) declares the method `groupBy` (line 163), and several of its implementations provide it.

Consider a call `set.groupBy(f)` where `set` is statically a `PersistentSet<String>` and the object it holds is an instance of `PersistentSet1` (the class in the same package that stores exactly one element). Which method runs?

Write the answer to `ANSWER.txt` in the repository root as one line, `path:line`: the path of the source file that defines that method, relative to the repository root, and the line of its definition on which the method's name appears.
