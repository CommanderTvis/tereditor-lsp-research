# Every session creation leaks an orphaned Permissions/Preferences row set (UserId NULL, unreachable by cascade)

### Describe the bug

Every **session creation** inserts a complete orphaned row set into `Permissions` (24 rows, one per `PermissionKind`) and `Preferences` (13 rows), all with `UserId = NULL`.

These rows can never be collected again. The foreign key is declared `ON DELETE CASCADE`, but a row whose `UserId` is `NULL` has no parent to cascade from, so it survives user deletion, server upgrades and any normal maintenance.

On my server this has accumulated:

| table | total | orphaned (`UserId IS NULL`) | legitimate |
|---|---|---|---|
| `Permissions` | 689,880 | **689,808 (99.99 %)** | 72 (24 kinds × 3 users) |
| `Preferences` | 373,685 | **373,646 (99.99 %)** | 39 (13 kinds × 3 users) |

That is ~1.06 M dead rows for 111 useful ones, accumulated in roughly 30 days on a **3-user** server.

### Measured trigger

Live capture at 5 s resolution over a logout / SSO re-login / playback sequence, correlating the row counts with `ActivityLogs`:

```
01:04:33  SessionStarted            (browser, OIDC flow)
01:04:33  AuthenticationSucceeded
01:04:33  SessionStarted            (desktop client)
01:04:33  Permissions +48   Preferences +26     = 2 × (24 and 13)
```

**Two** row sets for **two `SessionStarted`** events but only **one** `AuthenticationSucceeded`. The leak therefore tracks **session creation**, not authentication — one of the two sessions leaked without any authentication of its own.

What does **not** trigger it, over 27 minutes of cumulative observation:

- a client open and idle
- browsing the web UI
- scheduled tasks and background timers

### Ruled out

- **Mass user creation/deletion** — `Users.InternalId` is 2, 3, 4; only about four accounts have ever existed on this instance.
- **The 10.11 EF Core migration** — rows are still being created today, long after every migration in `__EFMigrationsHistory` completed.
- **A server-side timer** — counters stayed flat for 27 minutes with no client activity, while `journalctl` showed normal background load.

### Schema

```sql
CREATE TABLE "Permissions" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Permissions" PRIMARY KEY AUTOINCREMENT,
    "Kind" INTEGER NOT NULL,
    "Permission_Permissions_Guid" TEXT NULL,
    "RowVersion" INTEGER NOT NULL,
    "UserId" TEXT NULL,
    "Value" INTEGER NOT NULL,
    CONSTRAINT "FK_Permissions_Users_UserId" FOREIGN KEY ("UserId")
        REFERENCES "Users" ("Id") ON DELETE CASCADE
)
```

`Permission_Permissions_Guid` is `NULL` on 100 % of rows, so the orphans reference nothing at all through either column.

The orphaned rows carry `RowVersion = 1`; the 72 legitimate ones carry `RowVersion = 0`. The legitimate rows also sit at the very **end** of the `Id` sequence, i.e. they were written after the accumulated garbage.

The `Kind` values repeat in blocks of 24 in `Id` order, one full `PermissionKind` set per event.

### To reproduce

1. `SELECT COUNT(*) FROM Permissions WHERE UserId IS NULL;`
2. Open a new client session (any client).
3. Run the count again — it grows by exactly 24, and `Preferences` by 13.

### Expected behaviour

Creating a session should not persist a `User`'s default permission and preference collections detached from any user. Either they should be attached to the owning user, or not written at all.

### Impact

Unbounded growth proportional to the number of sessions ever created. Roughly one million rows per month here, on a small three-user instance; a busy server with many clients would grow considerably faster.

Not fatal — the rows are small and lookups are indexed — but they are unreachable by cascade, unaffected by user deletion, and are pure loss in every backup. A `VACUUM` does not help: `freelist_count` is 0, because nothing has ever been deleted.

Cleanup requires a manual `DELETE FROM Permissions WHERE UserId IS NULL` (and the same on `Preferences`) followed by `VACUUM`, which is not something an end user should have to discover.

### Possibly related

[#16298](https://github.com/jellyfin/jellyfin/issues/16298) — `SetPermission()` / `UpdateUserAsync()` not persisting. Same entity and likely the same write path, with the inverse symptom (rows missing instead of orphaned).

### System

- Jellyfin **10.11.11**, container (Podman)
- SQLite, WAL journal mode, `jellyfin.db` 35 MiB
- 3 users, ~5,500 library items
- Plugins: SSO-Auth 4.0.0.4 (OIDC), Webhook, Intro Skipper, File Transformation, and metadata providers

The SSO plugin doubles the rate, since each login opens both a browser session and a client session, but it is not the cause — a `SessionStarted` without its own authentication leaks just the same.

