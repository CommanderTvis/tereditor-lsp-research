# Compiled query with sql function and LoadWith

### Description

I get an LinqToDBException exception when using LoadWith() in a compiled query with a custom function in the latest linq2db master (5e8a0b7).

Removing either Compile() or LoadWith() works. Perhaps related to #5805.

### Reproduction Steps

```
var query = CompiledQuery.Compile<TestDB, int, IEnumerable<TestTableA>>(static (db, key) => db.TestTableAs.Where(a => a.Key == key && SqlFunctions.GetUtcDate() > DateTime.Today).LoadWith(a => a.ATestTableBs));
var entity = query(DB, 1).First();

public static class SqlFunctions
{
	[Sql.Function("GETUTCDATE", ServerSideOnly = true)]  // SQL Server
	public static DateTime GetUtcDate() => DateTime.UtcNow;
}
```

### Exception details

Message: 
LinqToDB.LinqToDBException : The LINQ expression could not be converted to SQL.
Expression:
((TestDB)(ps[0])).TestTableAs
	.Where(a => a.Key == (int)(ps[1]) && SqlFunctions.GetUtcDate() >  /* DateTime.op_GreaterThan(...) */ DateTime.Today)

  Stack Trace: 
ExpressionBuilder.BuildSequence(BuildInfo buildInfo) line 505
ExpressionBuilder.Build[T](IQueryExpressions& expressions) line 231
Query`1.CreateQuery(ExpressionTreeOptimizationContext optimizationContext, ParametersContext parametersContext, IDataContext dataContext, IQueryExpressions& expressions) line 223
Query`1.GetQuery(IDataContext dataContext, IQueryExpressions& expressions, Boolean& dependsOnParameters) line 200
ExpressionQuery`1.GetQuery(IQueryExpressions& expression, Boolean cache, Boolean& dependsOnParameters) line 91
IEnumerable<T>.GetEnumerator() line 353
IEnumerable<TEntity>.GetEnumerator() line 116
Enumerable.TryGetFirst[TSource](IEnumerable`1 source, Boolean& found)
Enumerable.First[TSource](IEnumerable`1 source)
QueryTests.Query_CustomFunction() line 223
RuntimeMethodHandle.InvokeMethod(Object target, Void** arguments, Signature sig, Boolean isConstructor)
MethodBaseInvoker.InvokeWithNoArgs(Object obj, BindingFlags invokeAttr)

### Regression?

_No response_

### Linq To DB version

master (5e8a0b7)

### .NET version

8

### Database

SQL Server

### Database provider

_No response_

### Operating system

_No response_

### Configuration

_No response_
