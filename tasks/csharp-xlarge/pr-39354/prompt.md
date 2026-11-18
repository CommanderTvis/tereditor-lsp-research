# Microsoft.Data.Sqlite: GetValues rejects an array shorter than the row, unlike the IDataRecord contract

`SqliteDataReader.GetValues` throws when the array is shorter than the row, where the `IDataRecord` contract says it copies what fits. (Split out of #39343 so each change can be reviewed on its own.)

### What the documentation says

[IDataRecord.GetValues](https://learn.microsoft.com/dotnet/api/system.data.idatarecord.getvalues), Remarks:

> You can pass an Object array that contains fewer than the number of columns that are contained in the resulting row. Only the amount of data the Object array holds is copied to the array.

### Why this is a bug

The contract explicitly allows a short array and says what happens: the first `values.Length` columns are copied and that count is returned. Microsoft.Data.Sqlite throws `IndexOutOfRangeException` instead, so code that reads only the leading columns of a wide row into a fixed-size buffer (valid against SqlClient, Npgsql and MySqlConnector) fails here.

```csharp
using var reader = connection.ExecuteReader("SELECT 1, 2, 3");
reader.Read();
reader.GetValues(new object[2]);   // IndexOutOfRangeException; documented: copies 2 values, returns 2
```

The current behaviour is pinned by `GetValues_throws_when_too_narrow`. I have a small change that follows the documented contract (copy `Math.Min(values.Length, FieldCount)` values and return that count) and replaces that test; I'll link it here.

Found with https://github.com/pengdows/pengdows.AdoNetApiTest.conformance

