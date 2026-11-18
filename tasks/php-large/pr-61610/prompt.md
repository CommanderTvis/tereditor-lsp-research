# Query string question mark regression after 12.69.2

### Laravel Version

12.69.2

### PHP Version

8.5.10

### Database Driver & Version

MariaDB 11.8.9 on Linux 6.18.50 64bit

### Description

After upgrading to 12.69.2 PHPUnit tests containing assertions with query strings fails as `?` gets replaced by its encoded form `%3F`. Note this `?` is the query string delimiter itself (e.g.  `/search?q=*0*`), not a string in the query string parameter (e.g. `/search?q=*0*?`). Other special characters are also encoded (e.g. `&` becomes `&amp;`).

### Steps To Reproduce

1. Take the following PHPUnit test:

    ```php
    public function testPageToSearch()
    {
        $response = $this->actingAs($user)
            ->from(url('/search?q=*0*&pageSize=all'))
            ->get(route('page.show', ['id' => 99]));
    
        $response->assertStatus(200);
        $response->assertSeeInOrder([
            '/search/99?q=*0*&pageSize=all',
            'Back to Search'
        ]);
    }
    ```

2. Running on 12.69.1:

    ```console
    $> vendor/bin/phpunit --filter testPageToSearch tests/Feature/Http/Controllers/SearchTest.php
    PHPUnit 12.5.35 by Sebastian Bergmann and contributors.
    
    Runtime:       PHP 8.5.10
    Configuration: ~/code/app/phpunit.xml
    
    .                                                                   1 / 1 (100%)
    
    Time: 00:00.283, Memory: 56.50 MB
    
    OK (1 test, 2 assertions)
    ```

3. Running on 12.69.2:

    ```console
    $> vendor/bin/phpunit --filter testPageToSearch tests/Feature/Http/Controllers/SearchTest.php
    PHPUnit 12.5.35 by Sebastian Bergmann and contributors.
    
    Runtime:       PHP 8.5.10
    Configuration: ~/code/app/phpunit.xml
    
    F                                                                   1 / 1 (100%)
    
    Time: 00:00.243, Memory: 61.50 MB
    
    There was 1 failure:
    
    1) Tests\Feature\Http\Controllers\SearchTest::testPageToSearch
    Failed asserting that Failed asserting that
    '<a href="/page/99%3Fq=*0*&amp;pageSize=all">Back to Search</a>'
    contains "/page/99?q=*0*&pageSize=all" in specified order.
    
    vendor/laravel/framework/src/Illuminate/Testing/TestResponseAssert.php:45
    vendor/laravel/framework/src/Illuminate/Testing/TestResponse.php:738
    tests/Feature/Http/Controllers/SearchTest.php:44
    
    FAILURES!
    Tests: 1, Assertions: 2, Failures: 1.
    ```

4. Note how `?` and `&` was replaced by their encoded form `%3F` and `&amp;` on 12.69.2 response.
