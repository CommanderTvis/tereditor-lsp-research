# Oracle: dispatch of PersistentSet#groupBy for PersistentSet1

Derived by reading the pinned source, no language server. `PersistentSet1` implements `PersistentSet` and declares `groupBy`
(with `@Override`) on line 111 of its file; it has no superclass. The other implementations (PersistentSet0, PersistentSetTrie) are different receivers.
