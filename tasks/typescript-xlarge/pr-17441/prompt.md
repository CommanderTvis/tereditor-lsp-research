# Race condition in defaultUpdateJobs prevents safe multi-worker job processing

## Description

The job claiming mechanism uses a non-atomic **find-then-update** pattern that creates a classic TOCTOU (time-of-check-time-of-use) race condition. This prevents safely running multiple workers against the same queue, as two workers can claim and execute the same job simultaneously.

## Affected Code

This affects **both** code paths:

### 1. Drizzle adapter: `@payloadcms/drizzle/dist/updateJobs.js` (active path for PostgreSQL/SQLite)

```javascript
export const updateJobs = async function updateMany({ id, data, limit, req, returning, sort, where }) {
    // ...

    // Step 1: FIND jobs matching WHERE clause (processing = false)
    const jobs = await findMany({
        adapter: this,
        collectionSlug: 'payload-jobs',
        fields: collection.flattenedFields,
        limit,
        pagination: false,
        req,
        sort,
        tableName,
        where: whereToUse   // ← processing = false
    });

    // Step 2: UPDATE each job individually
    // TODO comment in source: "We need to batch this to reduce the amount of db calls"
    for (const job of jobs.docs) {
        const result = await upsertRow({
            id: job.id,
            // ...
            data: { ...job, ...data },  // ← sets processing = true
        });
        results.push(result);
    }
    return results;
};
```

### 2. Default fallback: `payload/dist/database/defaultUpdateJobs.js`

Same pattern — `this.find()` then loop of `this.updateOne()`.

### 3. Caller: `payload/dist/queues/operations/runJobs/index.js`

The comment on line 125-126 acknowledges the problem:

> "Find all jobs and ensure we set job to processing: true **as early as possible to reduce the chance of** the same job being picked up by another worker"

"Reduce the chance" is not sufficient — it needs to be prevented entirely.

## The Race Condition

```
Worker A                              Worker B
────────                              ────────
findMany WHERE processing=false
  → sees Job #1, Job #2
                                      findMany WHERE processing=false
                                        → sees Job #1, Job #2 (same jobs!)

upsertRow Job #1: processing=true
upsertRow Job #2: processing=true
                                      upsertRow Job #1: processing=true (overwrites!)
                                      upsertRow Job #2: processing=true (overwrites!)

Both workers now execute Job #1 and Job #2 → duplicate execution
```

The gap between `findMany` (Step 1) and the `upsertRow` loop (Step 2) allows concurrent workers to both see the same jobs as `processing = false` and both claim them.

The caller passes `disableTransaction: true`, and while `updateJobs` wraps in a transaction via `getTransaction()`, a transaction alone doesn't prevent this. Without row-level locking (`SELECT ... FOR UPDATE SKIP LOCKED`), two transactions can both read `processing = false` and both succeed.

## Impact

- **Duplicate job execution**: The same job runs on multiple workers simultaneously
- **Data corruption**: Jobs that modify shared state (e.g., importing events into a dataset) produce incorrect results
- **Effectively limits deployment to 1 worker per queue**: Any multi-worker setup risks duplicate execution

## Expected Behavior

Job claiming should be **atomic** — once a worker claims a job, no other worker can claim the same job. This is a standard requirement for any job queue system.

## Suggested Fix

For PostgreSQL, replace the find-then-update with an atomic claim:

```sql
UPDATE payload_jobs
SET processing = true, "updated_at" = NOW()
WHERE id IN (
  SELECT id FROM payload_jobs
  WHERE processing = false
    AND "completed_at" IS NULL
    AND "has_error" != true
  ORDER BY "created_at"
  LIMIT 10
  FOR UPDATE SKIP LOCKED  -- critical: skip rows already locked by another worker
)
RETURNING *;
```

`FOR UPDATE SKIP LOCKED` is the standard pattern used by every major job queue (pg-boss, Graphile Worker, Que, good_job, etc.) to safely dequeue work across concurrent workers.

For the drizzle adapter specifically, this could be implemented using drizzle's raw SQL or query builder rather than the `findMany` → `upsertRow` loop.

## Workarounds

1. **Patch the drizzle `updateJobs`** to use an atomic SQL query
2. **Use separate queues per worker** (e.g., `ingest-1`, `ingest-2`) with one worker per queue, distributing jobs across queues at enqueue time
3. **Run only 1 worker per queue** (limits horizontal scaling)

## Environment

- Payload: 3.80.0
- Database adapter: `@payloadcms/db-postgres` 3.80.0 (uses `@payloadcms/drizzle`)
- Database: PostgreSQL 17 + PostGIS 3.5
