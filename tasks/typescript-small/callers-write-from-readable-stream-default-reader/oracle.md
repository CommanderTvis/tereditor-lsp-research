# Oracle: public entry points that reach writeFromReadableStreamDefaultReader

Derived without a language server: a static call graph of every top-level function of `src/` built by a text script
(bodies by column-0 declarations, calls as `name(` not preceded by `.`), then every edge on the paths below checked by
hand against

    rg -n 'writeFromReadableStream(DefaultReader)?\(|responseViaCache\(|responseViaResponseObject\(|getRequestListener\(|createAdaptorServer\(' src

- `writeFromReadableStreamDefaultReader` (src/utils.ts) is called by `writeFromReadableStream` (src/utils.ts) and by
  `responseViaResponseObject` (src/listener.ts:405).
- `writeFromReadableStream` is called by `responseViaCache` (src/listener.ts:249, :313).
- `responseViaCache` is called by `responseViaResponseObject` (:346) and by the closure inside `getRequestListener`
  (:505); `responseViaResponseObject` is called by that closure too (:528).
- `getRequestListener` is called by `createAdaptorServer` (src/server.ts:9), which is called by `serve`
  (src/server.ts:30).

No other module calls these helpers: `serveStatic`, `getConnInfo`, `earlyHints` and `upgradeWebSocket` reach none of
them (`serveStatic` uses `createStreamBody` only).

Judgement calls: none beyond the counting rules stated in the prompt.
