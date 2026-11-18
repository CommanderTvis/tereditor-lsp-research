# Header object passed to c.body() is mutated, so reusing it returns 500 from the second request on

### What version of `@hono/node-server` are you using?

2.1.1 (with `hono` 4.13.8, Node v24.19.0, macOS)

### What is the problem?

When a handler passes a plain object as the third argument of `c.body()`, the adapter writes `Content-Length` **into that object**. If the object is reused across responses — a module-level constant, for example — the next response fails with `TypeError: v is not iterable` and the server returns 500.

So the first request succeeds and every subsequent one fails, which is an unpleasant failure mode to debug: it looks like a caching or concurrency problem rather than a mutated constant.

### Minimal reproduction

```js
import { serve } from '@hono/node-server';
import { Hono } from 'hono';

// A header object reused across responses, e.g. a module-level constant.
const HEADERS = { 'content-type': 'text/plain; charset=utf-8' };

const app = new Hono();
app.get('/', (c) => c.body(new Uint8Array([104, 105]), 200, HEADERS));

serve({ fetch: app.fetch, port: 3999 }, async () => {
  for (let i = 1; i <= 2; i++) {
    const res = await fetch('http://127.0.0.1:3999/');
    console.log(`request ${i}: ${res.status}`);
  }
  console.log("the caller's object is now:", JSON.stringify(HEADERS));
  process.exit(0);
});
```

Output:

```
request 1: 200
TypeError: v is not iterable
request 2: 500
the caller's object is now: {"content-type":"text/plain; charset=utf-8","Content-Length":2}
```

### Cause

In `src/listener.ts`, when `header` is a plain object the `Content-Length` is assigned directly to it:

https://github.com/honojs/node-server/blob/main/src/listener.ts#L228-L235

```ts
if (!hasContentLength) {
  if (typeof body === 'string') {
    header['Content-Length'] = Buffer.byteLength(body)
  } else if (body instanceof Uint8Array) {
    header['Content-Length'] = body.byteLength
  } else if (body instanceof Blob) {
    header['Content-Length'] = body.size
  }
}
```

The `Headers` and array branches just above build a new object via `buildOutgoingHttpHeaders`, so only the plain-object path mutates its input. Since Hono keeps the caller's object as the response's header init, that write lands on the object the handler owns.

The 500 on the following request then comes from Hono's side: `Context.#newResponse` walks the header record and treats any non-string value as an iterable of values, and `Content-Length` is now a **number**:

```js
if (typeof v === 'string') responseHeaders.set(k, v)
else { responseHeaders.delete(k); for (const v2 of v) responseHeaders.append(k, v2) }   // ← v is a number
```

### Why it is easy to miss

`app.request()` never goes through this adapter, so a test suite that exercises handlers in-process passes cleanly while production fails from the second request onward. In our case the bug reached a deployed service with full coverage of the affected route.

### Suggested fix

Copy before writing, so the caller's object is left as it was:

```ts
if (!hasContentLength) {
  const length =
    typeof body === 'string' ? Buffer.byteLength(body)
    : body instanceof Uint8Array ? body.byteLength
    : body instanceof Blob ? body.size
    : undefined
  if (length !== undefined) {
    header = { ...header, 'Content-Length': length }
  }
}
```

Using a string value would also be more consistent with the rest of the header record, though the copy is the part that fixes the reuse case.

Happy to open a PR if the approach looks right.

