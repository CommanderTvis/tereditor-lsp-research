Can't use masked and union together

Let's say I want to define a struct for user events, using a discriminated union. Sample input data looks like:

```
const inputCreated = {
    eventType: 'USER_CREATED',
    userId: 1234,
    extraField: 'ignore me',
};

const inputUnsubscribed = {
    eventType: 'UNSUBSCRIBE',
    email: 'foo@example.com`,
    extraField: 'ignore me',
};
```

I might start off with this struct definition:

```
const EventStruct1 = s.union([
    s.type({
        eventType: s.literal('USER_CREATED'),
        userId: s.number(),
    }),
    s.type({
        eventType: s.literal('UNSUBSCRIBE'),
        email: s.string(),
    }),
]);
```

Which works, but keeps the `extraField`:

```
const event = s.create(inputCreated, EventStruct1);
console.log(event); // contains extraField
```

So I try to replace `type` with `object` and use `masked`:

```
const EventStruct2 = s.union([
    s.masked(
        s.object({
            eventType: s.literal('USER_CREATED'),
            userId: s.number(),
        }),
    ),
    s.masked(
        s.object({
            eventType: s.literal('UNSUBSCRIBE'),
            email: s.string(),
        }),
    ),
]);
```

Now this code throws an error (and a pretty cryptic error at that):

```
// Throws: Expected the value to satisfy a union of `object | object`, but received: [object Object]
const event = s.create(inputCreated, EventStruct2);
```

Moving the `masked` outside the `union` doesn't work either:

```
const EventStruct3 = s.masked(
    s.union([
        s.object({
            eventType: s.literal('USER_CREATED'),
            userId: s.number(),
        }),
        s.object({
            eventType: s.literal('UNSUBSCRIBE'),
            email: s.string(),
        }),
    ]),
);

// Throws: Expected the value to satisfy a union of `object | object`, but received: [object Object]
const event = s.create(inputCreated, EventStruct3);
```

Is there a way to implement a union where we strip out unknown properties?
