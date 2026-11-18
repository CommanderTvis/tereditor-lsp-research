# Composite string primary keys containing underscores collapse distinct entities during hydration

### Issue description

Distinct composite primary keys can produce the same internal hydration key when string components contain underscores. A query then drops an entity; with joined relations, rows from different entities can be combined.

### Expected Behavior

The two stored records with keys `("a_b", "c")` and `("a", "b_c")` should produce two entities, each retaining its own related rows.

### Actual Behavior

The database contains two rows, but `find()` returns one entity. `RawSqlResultsToEntityTransformer.group()` joins primary-key values with `"_"`, so both keys become `"a_b_c"`. The collision occurs while constructing entities from SQL results.

### Steps to reproduce

Run this TypeScript example with TypeORM, `sql.js`, and `reflect-metadata`; enable `experimentalDecorators` and `emitDecoratorMetadata` in tsconfig.

```typescript
import "reflect-metadata";
import { DataSource, Entity, PrimaryColumn } from "typeorm";

@Entity()
class Item {
    @PrimaryColumn()
    namespace: string;

    @PrimaryColumn()
    key: string;
}

async function main() {
    const source = await new DataSource({
        type: "sqljs", entities: [Item], synchronize: true,
    }).initialize();
    try {
        const items = source.getRepository(Item);
        await items.insert([
            { namespace: "a_b", key: "c" },
            { namespace: "a", key: "b_c" },
        ]);
        console.log("Stored rows:", await items.count());
        console.log("Hydrated entities:", await items.find());
    } finally {
        await source.destroy();
    }
}
main().catch(console.error);
```

Current output: `Stored rows: 2`, followed by one hydrated entity. Expected: two hydrated entities.

### Additional Context

The proposed fix encodes the normalized composite values as a JSON tuple, preserving component boundaries. The existing single-column key behavior is retained. Regression tests also cover joined children and keys with repeated/adjacent underscores.

I searched existing issues and open/closed PRs for composite-key collisions, underscores, missing entities, and the transformer. Related hydration work in #12824 retains underscore joining; #12806 adds a separate streaming API. Neither patch fixes this existing grouping path.

### My Environment

| Dependency | Version |
| --- | --- |
| Operating system | Windows |
| Node.js | 22.17.1 |
| TypeScript | 5.9.3 |
| TypeORM | master at f279fd1367f24ad108a1b11cf833f1620274088d (package version 1.1.1) |
| SQL.js | 1.14.2 |
| better-sqlite3 | 12.11.1 |

### Relevant Database Driver(s)

Reproduced with SQL.js and better-sqlite3. Other database engines were not run.

### Are you willing to resolve this issue by submitting a Pull Request?

Yes; a fix and regression tests are ready.

