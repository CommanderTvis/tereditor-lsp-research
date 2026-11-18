# Adding an unrelated route can change duplicate path parameter values

### What version of Hono are you using?

4.13.8. Also reproduced on current main (52febbcc).

### What runtime/platform is your app running on? (with version if possible)

Node.js 25.2.1

### What steps can reproduce the bug?

Both apps declare the same route and receive the same request. The second one only adds an unrelated `/a`.

```ts
import { Hono } from 'hono'
import { getRouterName } from 'hono/dev'

const a = new Hono()
a.get('/:id/:id/x', (c) => c.text(c.req.param('id')))
const resA = await a.request('/123/456/x')
console.log(await resA.text()) // 123
console.log(getRouterName(a))  // SmartRouter + RegExpRouter

const b = new Hono()
b.get('/:id/:id/x', (c) => c.text(c.req.param('id')))
b.get('/a', (c) => c.text('a'))
const resB = await b.request('/123/456/x')
console.log(await resB.text()) // 456
console.log(getRouterName(b))  // SmartRouter + TrieRouter
```

The request never reaches `/a`, but adding that route changes what `c.req.param('id')` returns.

### What is the expected behavior?

`c.req.param('id')` should not depend on which router `SmartRouter` picks.

In #1566 the first value was chosen when the same parameter name appears more than once in a path, and the shared router test still asserts it for `/:id/:id`:

```ts
it('self', () => {
  router.add('GET', '/:id/:id', 'foo')
  const res = match('GET', '/123/456')
  expect(res[0].params['id']).toBe('123')
})
```

### What do you see instead?

For `/:id/:id` and `/123/456`, `RegExpRouter`, `TrieRouter` and `LinearRouter` all return `123`. For `/:id/:id/x` and `/123/456/x`, `TrieRouter` returns `456` while the other two still return `123`.

With `/:id/:id/:id` and `/1/2/3` `TrieRouter` returns `2`, so it is not taking the last value either.

Under the default `SmartRouter`, adding `/a` switches the selection from `RegExpRouter` to `TrieRouter`, so the same request to the same route returns a different parameter value.

### Additional information

I traced this to `TrieRouter`. For `/:id/:id/x` the duplicate `id` gets overwritten while traversing the trie, and the two-segment case is handled differently in the final matching step.

That seems to be why `/:id/:id` returns `123` but `/:id/:id/x` returns `456`.

