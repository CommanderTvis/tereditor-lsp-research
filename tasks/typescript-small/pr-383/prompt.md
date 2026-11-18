# getRequestListener: uncaught `socket.destroySoon is not a function` in forceClose when the socket is mocked (e.g. fastify.inject via MCP SDK)

### What happened

`getRequestListener`'s request-drain logic force-closes the socket after `DRAIN_TIMEOUT_MS` when the incoming body was not fully read. `forceClose` assumes the socket is a real `net.Socket`:

```js
const forceClose = () => {
  cleanup();
  const socket = incoming.socket;
  if (socket && !socket.destroyed) {
    socket.destroySoon();
  }
};
```

When `incoming` is not a real `http.IncomingMessage` (for example a mocked request), `socket.destroyed` is `undefined` (so the guard passes) and `socket.destroySoon` does not exist, producing an **uncaught exception on a timer** that callers cannot catch:

```
TypeError: socket.destroySoon is not a function
 ❯ Timeout.forceClose node_modules/@hono/node-server/dist/index.mjs:390:14
 ❯ listOnTimeout node:internal/timers:585:17
 ❯ processTimers node:internal/timers:521:7
```

### How we hit this

The MCP TypeScript SDK (`@modelcontextprotocol/sdk`, `StreamableHTTPServerTransport`) uses `getRequestListener` to bridge Node req/res to fetch Request/Response. We mount that transport inside a Fastify route and integration-test it with `fastify.inject()` (light-my-request). light-my-request's `MockSocket` is a plain `EventEmitter` with neither `destroyed` nor `destroySoon`, so every injected MCP request schedules a 500 ms timer that later crashes the (vitest) worker with the unhandled `TypeError` above. Because it fires on a timer, it is timing-dependent and shows up as flaky "Unhandled Errors" in otherwise green test runs.

### Environment

- `@hono/node-server` 1.19.14 (via `@modelcontextprotocol/sdk` 1.29.0)
- Node v22.23.0
- light-my-request 6.6.0 (fastify inject)

### Suggested fix

Make `forceClose` defensive about non-standard sockets:

```js
const forceClose = () => {
  cleanup();
  const socket = incoming.socket;
  if (socket && !socket.destroyed) {
    if (typeof socket.destroySoon === 'function') {
      socket.destroySoon();
    } else {
      socket.destroy?.();
    }
  }
};
```

That keeps the drain behaviour for real sockets and turns the mocked-socket case into a no-op instead of an uncatchable crash. Happy to send a PR if that direction works for you.

