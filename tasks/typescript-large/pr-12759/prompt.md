# sqljs measures query execution time before the statement runs

### Issue description

On the sqljs driver, query execution time is measured before the statement runs, so `maxQueryExecutionTime` never fires and the `afterQuery` event carries a wrong `executionTime`.

### Expected Behavior

`executionTime` covers the time the query actually took, and a query slower than `maxQueryExecutionTime` reaches `logQuerySlow`.

Every other query runner takes `queryEndTime` after the execution call has returned. Postgres measures after `await databaseConnection.query(...)`, better-sqlite3 after `stmt.all()` / `stmt.run()`, expo after `await statement.executeAsync()`, react-native and nativescript inside the completion callback, spanner after `await executor.run(...)`.

### Actual Behavior

`SqljsQueryRunner.query()` takes `queryEndTime` right after `prepare()` and `bind()`. In sql.js the statement runs while `step()` is iterated, and that loop sits below the measurement, so only the preparation is timed.

```ts
const queryStartTime = Date.now()
    statement = databaseConnection.prepare(query)
    statement.bind(parameters)
const queryEndTime = Date.now()          // measurement ends here
    if (slow) logQuerySlow(...)          // and the check runs here
    while (statement.step()) { ... }     // the query actually runs here
    broadcastAfterQueryEvent(..., queryExecutionTime, ...)
```

A query that takes 393 ms of wall clock reports 3 ms, and never reaches `logQuerySlow`:

```
sqljs
  afterQuery executionTime   3
  actual elapsed           393
  logQuerySlow             not called

better-sqlite3 (same query, same options)
  logQuerySlow             150
  afterQuery executionTime 150
  actual elapsed           150
```

### Steps to reproduce

```js
const { DataSource } = require('typeorm')

// all of the work happens inside step(), so preparation and execution are separable
const slow = `WITH RECURSIVE counter(x) AS (
    SELECT 1 UNION ALL SELECT x + 1 FROM counter WHERE x < 2000000
) SELECT count(*) AS total FROM counter`

class Recorder {
    logQuery() {}
    logQueryError() {}
    logSchemaBuild() {}
    logMigration() {}
    log() {}
    logQuerySlow(time) {
        console.log('  logQuerySlow', time)
    }
}

class Sub {
    afterQuery(event) {
        console.log('  afterQuery executionTime', event.executionTime)
    }
}

async function run(type, extra) {
    const dataSource = new DataSource({
        type,
        maxQueryExecutionTime: 50,
        logger: new Recorder(),
        entities: [],
        ...extra,
    })
    await dataSource.initialize()
    dataSource.subscribers.push(new Sub())

    console.log(type)
    const started = Date.now()
    await dataSource.query(slow)
    console.log('  actual elapsed', Date.now() - started)

    await dataSource.destroy()
}

run('sqljs').then(() => run('better-sqlite3', { database: ':memory:' }))
```

### My Environment

| Dependency          | Version  |
| ---                 | ---      |
| Operating System    | macOS 15.7.7 |
| Node.js version     | 22.16.0  |
| Typescript version  | 5.9.3    |
| TypeORM version     | master (04ff4dae) |
| sql.js version      | 1.14.1   |

### Additional Context

Two things break because of this.

1. `maxQueryExecutionTime` is effectively inert on sqljs. Preparation is sub-millisecond, so the threshold is never crossed no matter how slow the query is.
2. Anything consuming `AfterQueryEvent.executionTime` for instrumentation gets a value that has nothing to do with the query.

Issue #10180 covered a different case, mysql2 queueing the query after `queryStartTime` was taken, and was closed by the stale bot rather than resolved. This one is the opposite end of the same measurement, and is specific to sqljs.

PR #12750 changes the clock source on these two lines from `Date.now()` to `PlatformTools.performanceNow()`. It leaves the measurement point where it is, so it does not affect this.

