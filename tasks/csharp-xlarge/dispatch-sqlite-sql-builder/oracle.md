# Oracle: SQL builder created for the SQLite.MS provider

Not derived from a language server. `ProviderName.SQLiteMS` is served by `SQLiteDataProviderMS`
(Source/LinqToDB/Internal/DataProvider/SQLite/SQLiteDataProvider.cs line 23), a sealed subclass of the abstract `SQLiteDataProvider`;
only the base class overrides `CreateSqlBuilder(MappingSchema, DataOptions)` (line 220), and it returns
`new SQLiteSqlBuilder(...)`, declared once in Internal/DataProvider/SQLite/SQLiteSqlBuilder.cs, namespace
`LinqToDB.Internal.DataProvider.SQLite`. The subclass does not override the method.
