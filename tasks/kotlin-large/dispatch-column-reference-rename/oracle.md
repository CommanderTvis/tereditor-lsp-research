# Oracle: dispatch of ColumnReference#rename for ResolvingColumnGroup

Derived by reading the pinned source, no language server. `ResolvingColumnGroup` (ColumnGroupImpl.kt:91) declares `override fun rename(newName: String) = ResolvingColumnGroup(source.rename(newName))` on line 104; the other `rename` in the same file (line 44) belongs to `ColumnGroupImpl`, which it wraps and is not the receiver. The KoDEx mirror under core/generated-sources holds a KDoc-expanded copy of the same file; the sources of record are those under core/src/main.
