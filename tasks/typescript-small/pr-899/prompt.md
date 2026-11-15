Describe incorrectly handles 'true' and 'false' types

Hey, Ian!

I found a problem while trying to write a struct for a described exact boolean value:
```typescript
const _true: Describe<true> = literal(true);
```

That's what we got here:
```
Type 'Struct<false, false>' is not assignable to type 'Describe<false>'.
  Types of property 'schema' are incompatible.
    Type 'false' is not assignable to type 'null'.ts(2322)
```

On the other hand, this code is correct:
```typescript
const _42: Describe<42> = literal(42);
```

Describe is using utility type `StructSchema`, so it seems that this type has a bug:
```typescript
let _42Schema: StructSchema<42>;           // 42
let _trueSchema: StructSchema<true>;       // null, but should be true
```

Here is the sandbox: https://codesandbox.io/s/fast-water-t00d7
