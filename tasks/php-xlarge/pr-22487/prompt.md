# Repository lookups that only need ids or existence load full entities

### Problem

Many lookups in Core and the Administration call `search()` (PHP) or `repository.search()` (Admin) but only read ids, a count, or whether a row exists.
Each of these hydrates full entities, joins requested associations, and dispatches `<entity>.loaded` events for data that is discarded.

A few places also run one lookup per item where one request for all items is enough.

### Expected

- Id-only and existence lookups use `searchIds()`.
- Per-item lookups are batched into one request, or read from data that is already loaded.

### Pull requests

Core, `searchIds` for id-only reads, split by domain:

- #22354 framework
- #22487 discovery
- #22488 after-sales
- #22489 fundamentals
- #22490 checkout

Administration, `searchIds` for id-only reads:

- #22355 inventory
- #22533 discovery
- #22534 framework
- #22535 checkout

Per-item lookups:

- #22407 product stream custom fields in one request
- #22409 listing criteria grid custom fields and orphaned media cleanup
- #22410 customer group SEO URLs use the loaded sales channel languages
