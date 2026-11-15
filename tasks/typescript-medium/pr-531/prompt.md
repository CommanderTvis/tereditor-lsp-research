[Proposal] Allow cors multiple origins

This has been one of the pain points of cors, because without special logic it is usually impossible to allow multiple origins. 

My proposal is to allow:
 ```js
app.use(
  '*',
  cors({
    origin: ['https://example.com', 'https://example.org'],
    //...
  })
)
```

And for the server to respond with the correct entry based on the [`Referrer`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer) header. (Falling back to `origin[0]` if empty/none apply)
