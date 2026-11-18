# Response body returned after client disconnect is never cancelled

## Summary

If the client disconnects while an async handler is still running, the `Response` body the handler then returns is never cancelled. The adapter reads one or two chunks and then waits on a closed socket forever. The stream's `cancel()` never runs, so whatever is producing the body (an upstream `fetch`, an SSE generator, a DB cursor) is held until the process exits.

Reproduces on `@hono/node-server` 1.19.14 and 2.1.5 (latest), with `hono` 4.13.13 on Node v22.23.2.

## Reproduction

`package.json`

```json
{ "type": "module", "dependencies": { "@hono/node-server": "2.1.5", "hono": "4.13.13" } }
```

`repro.mjs`

```js
import { createServer, request } from "node:http";
import { once } from "node:events";
import { getRequestListener } from "@hono/node-server";
import { readFileSync } from "node:fs";
const pkg = JSON.parse(readFileSync("node_modules/@hono/node-server/package.json", "utf8"));

let cancelled = false;
let closed;
const socketClosed = new Promise((resolve) => (closed = resolve));

const server = createServer(
  getRequestListener(async () => {
    await socketClosed;
    return new Response(
      new ReadableStream({
        start(controller) {
          controller.enqueue(new TextEncoder().encode("data: first\n\n"));
        },
        cancel() {
          cancelled = true;
        },
      }),
      { headers: { "content-type": "text/event-stream" } },
    );
  }),
);
server.on("request", (_req, res) => res.once("close", closed));
server.listen(0, "127.0.0.1");
await once(server, "listening");

const client = request(`http://127.0.0.1:${server.address().port}/`);
client.on("error", () => {});
client.end();
setTimeout(() => client.destroy(), 50);
await socketClosed;
await new Promise((r) => setTimeout(r, 1000));
console.log(`@hono/node-server ${pkg.version} on Node ${process.version}: body cancelled = ${cancelled}`);
server.closeAllConnections();
server.close();
```

```
$ npm i && node repro.mjs
@hono/node-server 2.1.5 on Node v22.23.2: body cancelled = false
```

The same script on 1.19.14 prints `body cancelled = false` too.

**Expected:** `body cancelled = true`. The socket is already closed, so the body should be cancelled, as it is when the disconnect happens after streaming starts.

## Cause

[`writeFromReadableStreamDefaultReader`](https://github.com/honojs/node-server/blob/4b47a0d8a5c12ed69a9f8493df69918f62fb61c0/src/utils.ts#L10-L51) attaches its `close`/`error` listeners to cancel the reader. If `outgoing` was already destroyed before the response arrived, `close` has already fired and never fires again. After that, either the pending `reader.read()` never settles (the producer is waiting for a consumer), or `writable.write()` returns `false` and `once('drain')` waits forever.

The same gap exists in a narrow window after the response arrives on a live socket: [`responseViaResponseObject`](https://github.com/honojs/node-server/blob/4b47a0d8a5c12ed69a9f8493df69918f62fb61c0/src/listener.ts#L364-L410) may `await new Promise((resolve) => setTimeout(resolve))` between its first reads and attaching those listeners. A disconnect inside that tick is missed in the same way.

`writeFromReadableStream` already returns early for `writable.destroyed`, but it doesn't cancel the stream, and the `responseViaResponseObject` path doesn't go through that check.

## Suggested fix

In `writeFromReadableStreamDefaultReader`, after attaching the listeners, cancel immediately if `writable.destroyed` (or `writable.closed`) is already true. Optionally, `responseViaResponseObject` could skip the body reads and cancel `res.body` when `outgoing.destroyed` is true on entry.

## Related, but separate

- #388 covers the reason passed to `cancel()` on `close`. Here `cancel()` is never called at all.
- In 1.19.x, a request `signal` first accessed after the disconnect also never aborts, because the controller is created lazily. 2.x fixes that half, but not the body.

## Workaround

A first middleware that reads `c.req.raw.signal` on entry (so 1.x creates the controller), and after `await next()` calls `c.res.body?.cancel(signal.reason)` if `signal.aborted`. This covers a disconnect before the handler returns, but not the `setTimeout` window above.

> AGENT GENERATED

