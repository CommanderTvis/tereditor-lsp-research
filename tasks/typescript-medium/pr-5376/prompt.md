# accepts() matches media types and language tags case-sensitively

`accepts()` compares the accept header entry and the supported value as raw strings, so a client that varies the case gets the default instead of a match.

```ts
const app = new Hono()
app.get('/', (c) =>
  c.text(accepts(c, { header: 'Accept', supports: ['text/html'], default: 'application/json' }))
)

// Accept: text/html  -> text/html
// Accept: TEXT/HTML  -> application/json
```

| Header | Value | supports | result |
| --- | --- | --- | --- |
| Accept | `text/html` | `['text/html']` | `text/html` |
| Accept | `TEXT/HTML` | `['text/html']` | default |
| Accept | `Text/Html` | `['text/html']` | default |
| Accept-Language | `en-US` | `['en-US']` | `en-US` |
| Accept-Language | `en-us` | `['en-US']` | default |
| Accept-Language | `EN` | `['en']` | default |

Both are case-insensitive. Media types by RFC 9110 §8.3.1, language tags by RFC 4647 §2.1. `en-us` is the one I would expect in the wild, since the uppercase region subtag is only a convention.

### Cause

```ts
// src/helper/accepts/accepts.ts
const matchType = (acceptType: string, supportedType: string): boolean => {
  if (acceptType === supportedType) {
    return true
  }
  ...
  return acceptMain === supportedMain
}
```

Nothing case-folds. The subtype wildcard path has the same problem, so `TEXT/*` does not match `text/html` either.

This is the same bug #5060 reported for `Content-Type`. #5064 fixed it for `parseBody()` and `validator()`, but `accepts()` was not part of that change.

PR is up. `defaultMatch()` returns the caller's own `supports` entry, so the casing an application registered is preserved.

