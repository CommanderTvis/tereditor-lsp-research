# Oracle: which updateJobs runs for the SQLite adapter

Derived by reading the code, no language server:

- `packages/payload/src/queues/utilities/updateJob.ts:93` calls `req.payload.db.updateJobs(args)`; `payload.db` is the
  object returned by `createDatabaseAdapter` (packages/payload/src/database/createDatabaseAdapter.ts), which spreads
  the arguments over its defaults and has no default `updateJobs` (the v4 migration guide says it was removed).
- `sqliteAdapter` (packages/db-sqlite/src/index.ts) passes the shorthand member `updateJobs` (line 175), imported at
  line 38 from `@payloadcms/drizzle`, which re-exports it at packages/drizzle/src/index.ts:82 from `./updateJobs.js`.
- The definition is `export const updateJobs: UpdateJobs = async function updateMany(` at
  packages/drizzle/src/updateJobs.ts:24. The function expression is named `updateMany`, which is not the exported
  `updateMany` of packages/drizzle/src/updateMany.ts; the exported const `updateJobs` is the binding that runs.
- Not it: packages/db-mongodb/src/updateJobs.ts:13 (MongoDB adapter) and the wrapper `updateJobs` at
  packages/payload/src/queues/utilities/updateJob.ts:47 (the caller's own module).

Judgement calls: the declaration line (24) is taken as the line of the `export const updateJobs` statement.
