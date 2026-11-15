Crypto createHash function is not type safe, breaking eTag middleware & timingSafeEqual

The [createHash](https://github.com/honojs/hono/blob/main/src/utils/crypto.ts#L26) function in the provided utils is not typesafe for any non-string based data. Any Object that does not natively cast itself to a string, such as JSON, will result in a hash of `[object Object]` which is `c1d44ff03aff1372856c281854f454e2e1d15b7c`. This value is found on one of the [Etag Tests](https://github.com/honojs/hono/blob/main/src/middleware/etag/index.test.ts#L27) as well.

You can replicate this with a basic eTag example where the content always changes:

```javascript
import {Hono} from 'hono';
import {etag} from 'hono/etag';

const app = new Hono();

app.use('*', etag());
// will never respond with a 304, as expected
app.get('/text', async context => context.text(JSON.stringify({random: crypto.randomUUID()})));
// will unexpectedly respond with a 304 on subsequent, despite content changing
app.get('/json', async context => context.json({random: crypto.randomUUID()}));

export default app;
```

This affects:
 - eTag Middleware
 - Buffer util: `timingSafeEqual` comparison
