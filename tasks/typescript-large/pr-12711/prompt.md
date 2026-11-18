# Batch save() silently deletes many-to-many junction rows of entities saved without their relation loaded (v1.0 regression)

### Issue description

Saving several entities in one `save()` call silently deletes the many-to-many junction rows of any entity in the batch whose relation property was not loaded — a v1.0.0 regression

### Expected Behavior

An entity whose many-to-many relation property is `undefined` (i.e. the relation was simply not loaded) should have its junction rows left untouched by `save()`. This is the documented contract — the 1.0 upgrade guide explicitly states that when the relation property is `undefined`, junction rows are left intact — and it is how 0.3.x behaves.

### Actual Behavior

When at least one *other* entity in the same `save()` call (or the same cascade) has that relation loaded, the entity with the unloaded relation gets **all of its junction rows deleted**. No error is raised; the associations are silently gone.

The 0.3.x behavior (and the intended v1 behavior per the upgrade guide) was: `undefined` relation → skip. Since v1.0.0, `undefined` is coerced to `[]`, which means "remove every binding".

### Steps to reproduce

Runnable script (better-sqlite3, but the bug is driver-independent):

```js
require("reflect-metadata")
const { DataSource, EntitySchema } = require("typeorm")

const Category = new EntitySchema({
    name: "Category",
    columns: {
        id: { type: Number, primary: true, generated: true },
        name: { type: String },
    },
})

const Post = new EntitySchema({
    name: "Post",
    columns: {
        id: { type: Number, primary: true, generated: true },
        title: { type: String },
    },
    relations: {
        categories: {
            type: "many-to-many",
            target: "Category",
            joinTable: { name: "post_categories" },
        },
    },
})

async function main() {
    const dataSource = new DataSource({
        type: "better-sqlite3",
        database: ":memory:",
        synchronize: true,
        entities: [Post, Category],
    })
    await dataSource.initialize()
    const postRepo = dataSource.getRepository("Post")
    const categoryRepo = dataSource.getRepository("Category")

    const c1 = await categoryRepo.save({ name: "c1" })
    const c2 = await categoryRepo.save({ name: "c2" })
    await postRepo.save({ title: "p1", categories: [c1] })
    await postRepo.save({ title: "p2", categories: [c2] })

    console.log(await dataSource.query("SELECT * FROM post_categories"))
    // [ { postId: 1, categoryId: 1 }, { postId: 2, categoryId: 2 } ]

    // p1 loaded WITH its categories, p2 loaded WITHOUT
    const p1 = await postRepo.findOne({ where: { id: 1 }, relations: { categories: true } })
    const p2 = await postRepo.findOne({ where: { id: 2 } }) // p2.categories === undefined

    p1.title = "p1 renamed"
    p2.title = "p2 renamed"
    await postRepo.save([p1, p2]) // <-- only titles changed

    console.log(await dataSource.query("SELECT * FROM post_categories"))
    // [ { postId: 1, categoryId: 1 } ]   <-- p2's junction row was deleted
    await dataSource.destroy()
}

main()
```

Output on `typeorm@1.1.0` (and current `master`): the second query shows p2's junction row deleted. On `typeorm@0.3.x` both rows survive.

### Root cause

Commit cab8fcb0e (`style(eslint): enable prefer-nullish-coalescing rule`, #12340) changed `ManyToManySubjectBuilder.buildForSubjectRelation` from

```ts
if (relatedEntities === null)
    // if value set to null its equal if we set it to empty array - all items must be removed from the database
    relatedEntities = []
if (!Array.isArray(relatedEntities)) return
```

to

```ts
relatedEntities ??= []
if (!Array.isArray(relatedEntities)) return
```

`??=` also matches `undefined`, so an unloaded relation — which previously fell through to the `!Array.isArray` guard and was **skipped** — is now treated as "relation set to empty, remove all junction rows". The removal only materializes when another subject in the same persistence group had the relation loaded (that is what makes the loader fetch the database-side relation ids for the whole group), which is why single-entity saves look fine and the bug surfaces on batch saves and cascades.

Notably, the same commit refactored the sibling `OneToManySubjectBuilder` and there it *kept* the explicit `undefined → return` guard — only the many-to-many builder lost it, which supports this being an accidental semantic change in a style-only commit.

### My Environment

| Dependency          | Version    |
| ---                 | ---        |
| Operating System    | Windows 11 |
| Node.js version     | 22.17.1    |
| Typescript version  | 5.9.3      |
| TypeORM version     | 1.1.0 (regression present since 1.0.0; reproduced on current `master`) |

### Relevant Database Driver(s)

All drivers — the bug is in driver-agnostic persistence code (reproduced with `better-sqlite3`).

### Are you willing to resolve this issue by submitting a Pull Request?

Yes, I have the time, and I know how to start — PR incoming (restores the `undefined → skip` guard, mirroring the one-to-many builder, plus a mixed-batch regression test).

