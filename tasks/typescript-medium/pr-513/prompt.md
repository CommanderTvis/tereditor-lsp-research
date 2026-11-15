Bearer middleware with Cloudflare Workers environment variables only works when multiple middlewares are defined

I'm trying to use the bearer auth middleware in a worker by providing the token from an environment variable. Currently i got the following code to work, but it only seems to work when i have multiple middlewares defined, otherwise it appears to be ignored.

```typescript
app.use('*',
    async (context, next) => {
        const auth = bearerAuth({ token: context.env.ARTICLE_MANAGER_TOKEN });
        await auth(context, next);
    },
    async (context, next) => {
        console.log('test');
        await next()
    }
);
```
