Job processing claims and updates jobs through `req.payload.db.updateJobs(args)` in
`packages/payload/src/queues/utilities/updateJob.ts` (line 93). In a project configured with the SQLite database
adapter (`sqliteAdapter` from `@payloadcms/db-sqlite`), which function definition runs when that call executes?

Write the result to `ANSWER.txt` in the repository root as one line, `relative/path:line`, giving the file and the
1-based line on which the definition of that function begins (the line of its `export`, `function` or `const`
declaration). Several files define functions named `updateJobs` or similar names; answer for the one that actually
runs for the SQLite adapter.
