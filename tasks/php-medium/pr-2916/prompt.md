# strtolower() expects parameter 1 to be string, int given

**Guzzle version(s) affected**: 7.3
**PHP version**: 7.4.19
**cURL version**: 7.76.1

I get this error:

`strtolower() expects parameter 1 to be string, int given {"userId":1,"exception":"[object] (TypeError(code: 0): strtolower() expects parameter 1 to be string, int given at /home/vagrant/xxx/vendor/guzzlehttp/psr7/src/Utils.php:28)`

after calling the PayPal API with this command:

```
$response = Http::withHeaders([
            'Accept: application/json',
            'Content-Type: application/json',
        ])
        ->withToken($paypal_account->access_token)
        ->get(env('PAYPAL_LIVE_API_URL').'/v1/reporting/transactions', [
            'start_date' => $start_date,
            'end_date' => $end_date,
            'fields' => $fields,
            'balance_affecting_records_only' => 'N',
            'page_size' => $page_size,
            'page' => $page
        ]);
```

This happend after my composer update updated guzzlehttp from psr7 1.8.2 to 2.0.0.

In the meantime I fixed this for me adding this to my composer.json:

`"guzzlehttp/psr7": "1.8.2",`





